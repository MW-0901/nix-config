(setq inhibit-startup-message t
      make-backup-files nil
      auto-save-default nil
      create-lockfiles nil)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(setq org-startup-indented t)
(windmove-default-keybindings)
(setq org-pretty-entities t
      org-use-sub-superscripts '{})
(add-hook 'org-mode-hook #'org-cdlatex-mode)
(org-babel-do-load-languages
 'org-babel-load-languages
 '((latex . t)))

;; Some eww stuff

(defun my-eww-strip-wikipedia-edit-text ()
  (when (and (eww-current-url)
             (string-match-p "wikipedia\\.org" (eww-current-url)))
    (goto-char (point-min))
    (while (search-forward "[edit]" nil t)
      (replace-match ""))))
(add-hook 'eww-after-render-hook #'my-eww-strip-wikipedia-edit-text)

(add-hook 'eww-after-render-hook
          (lambda ()
            (call-interactively #'eww-readable)))
(setq org-format-latex-options
      (plist-put org-format-latex-options :scale 2.0))
(defun die ()
  (interactive)
  (if (daemonp)
      (progn
        (message "Killing Emacs daemon...")
        (kill-emacs))
    (save-buffers-kill-emacs)))

(setq scroll-margin 10)

(let ((macro-file (expand-file-name "~/config/programs/emacs/user-macros.el")))
  (when (file-exists-p macro-file)
    (load-file macro-file)))
(with-eval-after-load 'org
  (setq org-startup-indented t))


(display-time-mode 1)
(display-battery-mode 1)

(setq battery-mode-line-format " [%p%%]")

(setq-default mode-line-format
              '(" " display-time-string battery-mode-line-string))


(let ((modules-dir (expand-file-name "modules" (file-name-directory load-file-name))))
  (add-to-list 'load-path modules-dir)
  (add-to-list 'load-path (expand-file-name "interface" modules-dir))
  (add-to-list 'load-path (expand-file-name "languages" modules-dir))
  (add-to-list 'load-path (expand-file-name "misc" modules-dir))
  (message "Loading modules from: %s" modules-dir))

(require 'lsp-mode)

(use-package markdown-mode
  :mode "\\.md\\'"
  :config
  (setq markdown-command "pandoc"))

(setq treesit-extra-load-path
      '("/run/current-system/sw/lib"))

(dolist (module '(ui
                  editing
                  completion
                  navigation
                  macros
                  webdev
                  python-editing
                  projects
                  dired-binds
                  svelte
                  ranger-conf
                  browser-integration
                  eat-shell
                  news
                  canvas
                  circe-irc
                  tramp-user-conf))
  (require module))
