;;; canvas.el --- Canvas grades and calendar integration -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'request)
(require 'json)
(require 'seq)
(require 'org)
(require 'org-agenda)
(require 'url)

(defconst canvas-grades--secrets-file
  (expand-file-name "~/.secrets/canvas.el"))

(when (file-exists-p canvas-grades--secrets-file)
  (load canvas-grades--secrets-file nil 'nomessage))

(defvar canvas-base-url nil)
(defvar canvas-access-token nil)

(defun canvas-grades--ensure-secrets ()
  (unless (and (stringp canvas-base-url)
               (stringp canvas-access-token))
    (user-error
     "`canvas-base-url` and `canvas-access-token` not found in ~/.secrets/canvas.el")))

(defface canvas-grades-course-name
  '((t :inherit font-lock-function-name-face :weight bold))
  "")

(defface canvas-grades-grade-a
  '((t :foreground "#2ecc71" :weight bold))
  "")

(defface canvas-grades-grade-b
  '((t :foreground "#3498db" :weight bold))
  "")

(defface canvas-grades-grade-c
  '((t :foreground "#f39c12" :weight bold))
  "")

(defface canvas-grades-grade-d
  '((t :foreground "#e67e22" :weight bold))
  "")

(defface canvas-grades-grade-f
  '((t :foreground "#e74c3c" :weight bold))
  "")

(defface canvas-grades-no-grade
  '((t :foreground "#95a5a6" :slant italic))
  "")

(defface canvas-grades-assignment-name
  '((t :foreground "#ecf0f1"))
  "")

(defface canvas-grades-graded
  '((t :foreground "#27ae60"))
  "")

(defface canvas-grades-pending
  '((t :foreground "#e67e22"))
  "")

(defface canvas-grades-date
  '((t :foreground "#7f8c8d" :slant italic))
  "")

(defun canvas-grades--parse-json ()
  (json-parse-buffer
   :array-type 'list
   :object-type 'alist
   :null-object nil
   :false-object nil))

(defun canvas-grades--request-pages (endpoint params callback)
  (canvas-grades--ensure-secrets)
  (let ((all '()))
    (cl-labels ((fetch-page (url)
                  (request
                    url
                    :type "GET"
                    :params params
                    :headers
                    `(("Authorization"
                       . ,(format "Bearer %s" canvas-access-token)))
                    :parser #'canvas-grades--parse-json
                    :success (cl-function
                              (lambda (&key data response &allow-other-keys)
                                (setq all (nconc all data))
                                (let ((link (request-response-header response "Link")))
                                  (if (and link
                                           (string-match
                                            "<\\([^>]+\\)>; rel=\"next\""
                                            link))
                                      (fetch-page (match-string 1 link))
                                    (funcall callback all))))))))
      (fetch-page
       (concat (string-trim-right canvas-base-url "/") "/api/v1" endpoint)))))

(defun canvas-grades--parse-iso8601 (iso-str)
  (when (and iso-str (stringp iso-str))
    (let* ((clean (replace-regexp-in-string "Z$" "+00:00" iso-str))
           (parsed (parse-iso8601-time-string clean)))
      parsed)))

(defun canvas-grades--days-ago (time)
  (when time
    (/ (float-time (time-subtract (current-time) time)) 86400)))

(defun canvas-grades--format-date (time)
  (when time
    (format-time-string "%b %d" time)))

(defun canvas-grades--recent-enough-p (time cutoff-days)
  (when time
    (<= (canvas-grades--days-ago time) cutoff-days)))

(defun canvas-grades--grade-face (grade-str)
  (cond
   ((string-match-p "^A" grade-str) 'canvas-grades-grade-a)
   ((string-match-p "^B" grade-str) 'canvas-grades-grade-b)
   ((string-match-p "^C" grade-str) 'canvas-grades-grade-c)
   ((string-match-p "^D" grade-str) 'canvas-grades-grade-d)
   ((string-match-p "^F" grade-str) 'canvas-grades-grade-f)
   ((string-match-p "^[0-9]" grade-str)
    (let ((score (string-to-number grade-str)))
      (cond
       ((>= score 90) 'canvas-grades-grade-a)
       ((>= score 80) 'canvas-grades-grade-b)
       ((>= score 70) 'canvas-grades-grade-c)
       ((>= score 60) 'canvas-grades-grade-d)
       (t 'canvas-grades-grade-f))))
   (t 'canvas-grades-no-grade)))

(defun canvas-grades--status-face (status)
  (cond
   ((member status '("graded" "published")) 'canvas-grades-graded)
   ((member status '("submitted" "pending_review")) 'canvas-grades-pending)
   (t 'canvas-grades-no-grade)))

(defun canvas-grades--find-enrollment (course)
  (seq-find
   (lambda (e) (string= (alist-get 'type e) "student"))
   (alist-get 'enrollments course)))

(defun canvas-grades--format-course-grade (enrollment)
  (let ((letter (alist-get 'computed_current_letter_grade enrollment))
        (score  (alist-get 'computed_current_score enrollment)))
    (cond
     ((and letter score) (format "%s (%.1f%%)" letter score))
     (letter letter)
     (score  (format "%.1f%%" score))
     (t "No grade yet"))))

(defun canvas-grades--format-assignment-line (assignment)
  (let* ((name       (alist-get 'name assignment))
         (max        (alist-get 'points_possible assignment))
         (submission (alist-get 'submission assignment))
         (earned     (when submission (alist-get 'score submission)))
         (letter     (when submission (alist-get 'grade submission)))
         (status     (when submission (alist-get 'workflow_state submission)))
         (graded-at  (when submission (alist-get 'graded_at submission)))
         (posted-at  (when submission (alist-get 'posted_at submission)))
         (date-str   (or graded-at posted-at))
         (parsed-time (canvas-grades--parse-iso8601 date-str))
         (pct        (when (and earned max (> max 0))
                       (/ (* earned 100.0) max))))
    (list :name      name
          :earned    earned
          :max       max
          :pct       pct
          :grade     (or letter "—")
          :status    (or status "not submitted")
          :date      parsed-time
          :sort-time (or parsed-time 0))))

(defvar-local canvas-grades--data nil)
(defvar-local canvas-grades--expanded '())

(defvar canvas-grades--known-graded (make-hash-table :test 'equal)
  "Hash table of assignment names already notified as graded.")

(defun canvas-grades--notify-new-grades (course-name assignments)
  (dolist (aplist assignments)
    (let ((status (plist-get aplist :status))
          (name   (plist-get aplist :name))
          (earned (plist-get aplist :earned))
          (max    (plist-get aplist :max)))
      (when (and (string= status "graded")
                 earned
                 (not (gethash name canvas-grades--known-graded)))
        (puthash name t canvas-grades--known-graded)
        (let ((msg (format "%s: %.1f/%.1f" name (or earned 0) (or max 0))))
          (message "Canvas graded — %s — %s" course-name msg)
          (when (executable-find "notify-send")
            (call-process "notify-send" nil 0 nil
                          "-u" "normal"
                          (format "Canvas: %s graded" course-name)
                          msg)))))))

(defun canvas-grades--fetch-all ()
  (message "Fetching Canvas grades…")
  (let ((grades-buffer (current-buffer)))
    (canvas-grades--request-pages
     "/courses"
     '(("enrollment_state" . "active")
       ("include[]"        . "total_scores"))
     (lambda (courses)
       (let ((remaining (length courses))
             (acc '())
             (cutoff-days 75))
         (dolist (course courses)
           (let* ((enr  (canvas-grades--find-enrollment course))
                  (name (alist-get 'name course))
                  (cid  (alist-get 'id course)))
             (when enr
               (canvas-grades--request-pages
                (format "/courses/%s/assignments" cid)
                '(("include[]" . "submission"))
                (lambda (assignments)
                  (let* ((formatted
                          (mapcar #'canvas-grades--format-assignment-line
                                  assignments))
                         (recent
                          (seq-filter
                           (lambda (a)
                             (let ((time (plist-get a :date)))
                               (or (null time)
                                   (canvas-grades--recent-enough-p time cutoff-days))))
                           formatted))
                         (sorted
                          (sort recent
                                (lambda (a b)
                                  (let ((ta (or (plist-get a :sort-time) 0))
                                        (tb (or (plist-get b :sort-time) 0)))
                                    (cond
                                     ((and (numberp ta) (numberp tb)) nil)
                                     ((numberp ta) nil)
                                     ((numberp tb) t)
                                     (t (time-less-p tb ta))))))))
                    (canvas-grades--notify-new-grades name sorted)
                    (push (cons name
                                (list :overall     (canvas-grades--format-course-grade enr)
                                      :assignments sorted))
                          acc))
                  (when (<= (cl-decf remaining) 0)
                    (with-current-buffer grades-buffer
                      (setq canvas-grades--data (nreverse acc))
                      (canvas-grades--refresh)
                      (message "Canvas grades loaded!")))))))))))))

(defun canvas-grades--refresh ()
  (let ((pos (point)))
    (let ((inhibit-read-only t))
      (erase-buffer)
      (insert (propertize "Canvas Grades\n\n" 'face '(:weight bold :height 1.2)))
      (dolist (c canvas-grades--data)
        (let* ((name    (car c))
               (plist   (cdr c))
               (overall (plist-get plist :overall))
               (open    (member name canvas-grades--expanded)))
          (insert (format "%s " (if open "▼" "▶")))
          (insert (propertize name 'face 'canvas-grades-course-name))
          (insert " — ")
          (insert (propertize overall 'face (canvas-grades--grade-face overall)))
          (insert "\n")
          (when open
            (dolist (aplist (plist-get plist :assignments))
              (let ((aname  (plist-get aplist :name))
                    (earned (plist-get aplist :earned))
                    (max    (plist-get aplist :max))
                    (pct    (plist-get aplist :pct))
                    (status (plist-get aplist :status))
                    (date   (plist-get aplist :date)))
                (insert "    ")
                (when date
                  (insert (propertize (format "[%s] " (canvas-grades--format-date date))
                                      'face 'canvas-grades-date)))
                (insert (propertize aname 'face 'canvas-grades-assignment-name))
                (insert ": ")
                (insert (propertize
                         (format "%s/%s"
                                 (if earned (format "%.1f" earned) "—")
                                 (if max    (format "%.1f" max)    "—"))
                         'face (if earned 'canvas-grades-graded 'canvas-grades-no-grade)))
                (when pct
                  (insert (propertize (format " (%.1f%%)" pct)
                                      'face (if earned 'canvas-grades-graded
                                              'canvas-grades-no-grade))))
                (insert " [")
                (insert (propertize status 'face (canvas-grades--status-face status)))
                (insert "]\n")))))))
    (goto-char pos)))

(defun canvas-grades-toggle ()
  (interactive)
  (let ((name (save-excursion
                (beginning-of-line)
                (when (looking-at "[▶▼] \\(.*?\\) —")
                  (match-string 1)))))
    (when name
      (if (member name canvas-grades--expanded)
          (setq canvas-grades--expanded (delete name canvas-grades--expanded))
        (push name canvas-grades--expanded))
      (canvas-grades--refresh))))

(defvar canvas-grades-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "RET") #'canvas-grades-toggle)
    (define-key map (kbd "g")   #'canvas-grades)
    (define-key map (kbd "q")   #'quit-window)
    map))

(define-derived-mode canvas-grades-mode special-mode "Canvas-Grades")

(defun canvas-grades ()
  (interactive)
  (let ((buf (get-buffer-create "*Canvas Grades*")))
    (with-current-buffer buf
      (canvas-grades-mode)
      (setq canvas-grades--expanded '()
            canvas-grades--data     nil)
      (canvas-grades--refresh)
      (canvas-grades--fetch-all))
    (pop-to-buffer buf)))

(defvar my/canvas-sync-timer nil)

(defun my/get-done-summaries (org-file)
  (let ((done (make-hash-table :test 'equal)))
    (when (file-exists-p org-file)
      (with-temp-buffer
        (insert-file-contents org-file)
        (goto-char (point-min))
        (while (re-search-forward "^\\* DONE \\(.+\\)" nil t)
          (puthash (string-trim (match-string 1)) t done))))
    done))

(defun my/clean-description (desc)
  (setq desc (replace-regexp-in-string "\n[ \t]" "" desc))
  (setq desc (replace-regexp-in-string "\\\\n" "\n  " desc))
  (setq desc (replace-regexp-in-string "\\\\," "," desc))
  (setq desc (replace-regexp-in-string "\\[\\([^]]+\\)\\] (\\([^)]+\\))" "[[\\2][\\1]]" desc))
  (setq desc (replace-regexp-in-string "^\\*" "  -" desc))
  (setq desc (replace-regexp-in-string "\n  \\*" "\n  -" desc))
  desc)

(defun my/parse-ics-to-org (ics-file org-file)
  (let ((done-items (my/get-done-summaries org-file)))
    (with-temp-file org-file
      (insert "#+TITLE: Canvas Assignments\n")
      (insert "#+STARTUP: content\n\n")
      (let ((ics-data (with-temp-buffer
                        (insert-file-contents ics-file)
                        (buffer-string)))
            (case-fold-search nil)
            (today (string-to-number (format-time-string "%Y%m%d"))))
        (dolist (event (split-string ics-data "BEGIN:VEVENT"))
          (when (string-match "SUMMARY:\\(.+\\)" event)
            (let ((summary  (string-trim (match-string 1 event)))
                  (date     "")
                  (raw-date 0)
                  (desc     ""))
              (when (string-match "DTSTART:\\([0-9]\\{8\\}\\)T\\([0-9]\\{6\\}\\)Z" event)
                (let* ((date-str    (match-string 1 event))
                       (time-str    (match-string 2 event))
                       (year        (string-to-number (substring date-str 0 4)))
                       (month       (string-to-number (substring date-str 4 6)))
                       (day         (string-to-number (substring date-str 6 8)))
                       (hour        (string-to-number (substring time-str 0 2)))
                       (min         (string-to-number (substring time-str 2 4)))
                       (sec         (string-to-number (substring time-str 4 6)))
                       (utc-time    (encode-time sec min hour day month year 0))
                       (local-time  (decode-time utc-time))
                       (local-year  (nth 5 local-time))
                       (local-month (nth 4 local-time))
                       (local-day   (nth 3 local-time)))
                  (setq raw-date (string-to-number (format "%04d%02d%02d" local-year local-month local-day)))
                  (setq date (format "<%04d-%02d-%02d>" local-year local-month local-day))))
              (when (>= raw-date today)
                (when (string-match "DESCRIPTION:\\(\\(?:.*\n\\(?:[ \t].*\n\\)*\\)\\)" event)
                  (setq desc (my/clean-description (match-string 1 event))))
                (let ((state (if (gethash summary done-items) "DONE" "TODO")))
                  (insert (format "* %s %s\n" state summary)))
                (insert (format "  SCHEDULED: %s\n" date))
                (when (and desc (not (string-empty-p desc)))
                  (insert (format "  %s\n" desc)))
                (insert "\n")))))))))

(defun my/sync-canvas-calendar ()
  (interactive)
  (let* ((ics-file (expand-file-name "~/.calendar/canvas.ics"))
         (org-file (expand-file-name "~/.calendar/canvas.org")))
    (unless (file-exists-p (file-name-directory ics-file))
      (make-directory (file-name-directory ics-file) t))
    (message "Downloading Canvas calendar...")
    (url-copy-file canvas-ics-url ics-file t)
    (message "Converting to org-mode...")
    (condition-case err
        (my/parse-ics-to-org ics-file org-file)
      (error (message "Error converting: %s" err)))
    (let ((ics-buffer (get-file-buffer ics-file)))
      (when ics-buffer (kill-buffer ics-buffer)))
    (when (derived-mode-p 'org-agenda-mode)
      (org-agenda-redo))
    (message "Canvas calendar synced!")))

(defun my/agenda-show-assignment ()
  (interactive)
  (org-agenda-switch-to)
  (delete-other-windows)
  (org-narrow-to-subtree)
  (org-show-subtree)
  (goto-char (point-min))
  (visual-line-mode 1)
  (text-scale-set 2)
  (read-only-mode 1))

(with-eval-after-load 'org-agenda
  (define-key org-agenda-mode-map (kbd "RET") 'my/agenda-show-assignment)
  (define-key org-agenda-mode-map (kbd "q")
              (lambda ()
                (interactive)
                (widen)
                (visual-line-mode -1)
                (text-scale-set 0)
                (read-only-mode -1)
                (org-agenda-quit))))

(when my/canvas-sync-timer
  (cancel-timer my/canvas-sync-timer))

(setq my/canvas-sync-timer
      (run-at-time "30 sec" (* 2 60 60) 'my/sync-canvas-calendar))

(global-set-key (kbd "C-c A") 'my/sync-canvas-calendar)
(global-set-key (kbd "C-c a") 'org-agenda)

(add-to-list 'org-agenda-files "~/.calendar/canvas.org")

(defun canvas ()
  (interactive)
  (delete-other-windows)
  (let ((buf (get-buffer-create "*Canvas Grades*")))
    (with-current-buffer buf
      (canvas-grades-mode)
      (setq canvas-grades--expanded '()
            canvas-grades--data     nil)
      (canvas-grades--refresh)
      (canvas-grades--fetch-all))
    (switch-to-buffer buf))
  (split-window-horizontally)
  (other-window 1)
  (let ((org-agenda-window-setup 'current-window))
    (org-agenda nil "a"))
  (other-window 1))

(provide 'canvas)
