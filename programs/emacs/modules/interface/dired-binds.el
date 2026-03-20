(defun dired-cwd ()
  "Open Dired in the current directory."
  (interactive)
  (dired default-directory))
(global-set-key (kbd "C-c f o") 'dired-cwd)

(defun wdired-cwd ()
  "Open wdired in the current directory."
  (interactive)
  (dired default-directory)
  (wdired-change-to-wdired-mode))

(global-set-key (kbd "C-c f O") 'wdired-cwd)
(provide 'dired-binds)

(defun dired-create-new-file ()
  "Create a new file in the current Dired directory and open it."
  (interactive)
  (let* ((dir (dired-current-directory))
         (filename (read-string "New file name: "))
         (filepath (expand-file-name filename dir)))    
    (if (file-exists-p filepath)
        (message "File already exists: %s" filepath)
      (write-region "" nil filepath)
      (message "Created file: %s" filepath))    
    (find-file filepath)))

(global-set-key (kbd "C-c f n") 'dired-create-new-file)
