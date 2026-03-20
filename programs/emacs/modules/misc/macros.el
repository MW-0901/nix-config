(defun toggle-macro-recording ()
  "Start or stop macro recording."
  (interactive)
  (if defining-kbd-macro
      (kmacro-end-macro nil)
    (kmacro-start-macro nil)))

(defun macro-save (name)
  "Save the last keyboard macro to ~/config/programs/emacs/user-macros.el with NAME.
If NAME already exists, prompt to rename the old definition to old-NAME."
  (interactive "sMacro name: ")
  (unless last-kbd-macro
    (user-error "No keyboard macro defined"))
  
  (let* ((macro-file (expand-file-name "~/config/programs/emacs/user-macros.el"))
         (name-symbol (intern name))
         (conflict-exists nil))
    
    (when (file-exists-p macro-file)
      (load-file macro-file)
      (setq conflict-exists (fboundp name-symbol)))
    
    (when conflict-exists
      (let ((response (read-char-choice
                       (format "Macro '%s' already exists. Rename old to 'old-%s'? (y/n): " name name)
                       '(?y ?n))))
        (if (eq response ?y)
            (let ((old-name (intern (concat "old-" name))))
              (fset old-name (symbol-function name-symbol))
              (message "Old macro renamed to 'old-%s'" name))
          (user-error "Macro save cancelled"))))
    
    (with-temp-buffer
      (when (file-exists-p macro-file)
        (insert-file-contents macro-file)
        (goto-char (point-min))
        (when (re-search-forward (format "^(fset '%s" name) nil t)
          (beginning-of-line)
          (let ((start (point)))
            (forward-sexp)
            (delete-region start (point))
            (when (looking-at "\n")
              (delete-char 1)))))
      
      (goto-char (point-max))
      (unless (bobp)
        (insert "\n\n"))
      (insert (format "(fset '%s\n  %S)\n" name last-kbd-macro))
      
      (write-region (point-min) (point-max) macro-file))
    
    (fset name-symbol last-kbd-macro)
    
    (message "Macro '%s' saved to %s" name macro-file)))

(defun bind-macro (macro-name keybind)
  "Bind an existing user-defined macro to a keybinding in user-macros.el."
  (interactive "sMacro name: \nsKeybinding (e.g., C-c p): ")
  
  (let* ((macro-file (expand-file-name "~/config/programs/emacs/user-macros.el"))
         (macro-symbol (intern macro-name)))
    
    (unless (file-exists-p macro-file)
      (user-error "No user macros file found. Save a macro first with macro-save"))
    
    (load-file macro-file)
    
    (unless (fboundp macro-symbol)
      (user-error "Macro '%s' not found. Available macros can be seen with M-x list-functions" macro-name))
    
    (with-temp-buffer
      (insert-file-contents macro-file)
      
      (goto-char (point-min))
      (when (re-search-forward (format "^(global-set-key.*'%s)" macro-name) nil t)
        (beginning-of-line)
        (let ((start (point)))
          (forward-line 1)
          (delete-region start (point))))
      
      (goto-char (point-max))
      (unless (bobp)
        (insert "\n"))
      (insert (format "(global-set-key (kbd \"%s\") '%s)\n" keybind macro-name))
      
      (write-region (point-min) (point-max) macro-file))
    
    (global-set-key (kbd keybind) macro-symbol)
    
    (message "Bound '%s' to %s" macro-name keybind)))

(global-set-key (kbd "C-c s") 'toggle-macro-recording)
(global-set-key (kbd "C-c S") 'macro-save)

(provide 'macros)
