(defun my/project-todo-file ()
  "Return TODO.org at the projectile project root, falling back to home."
  (expand-file-name "TODO.org"
                    (if (and (fboundp 'projectile-project-root)
                             (projectile-project-p))
                        (projectile-project-root)
                      "~")))

(setq org-capture-templates
      '(("t" "Project TODO" entry
         (file+headline my/project-todo-file "Tasks")
         "* TODO %?\n  %a\n  Captured: %U\n"
         :empty-lines 1)))

(global-set-key (kbd "C-c c") 'org-capture)

(provide 'capture)
