(use-package projectile
  :diminish projectile-mode
  :config
  (projectile-mode +1)
  
  (setq projectile-project-search-path '("~/Projects"))
  
  (setq projectile-track-known-projects-automatically t)
  
  (setq projectile-require-project-root nil)
  
  (setq projectile-indexing-method 'hybrid)
  
  (setq projectile-enable-caching t)
  
  :bind-keymap
  ("C-c p" . projectile-command-map))

(defun my/get-project-root ()
  (or (projectile-project-root)
      default-directory))

(provide 'projects)
