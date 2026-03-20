(which-key-mode)
(setq which-key-idle-delay 0.5)

(require 'helpful)
(global-set-key (kbd "C-h f") 'helpful-callable)
(global-set-key (kbd "C-h v") 'helpful-variable)
(global-set-key (kbd "C-h k") 'helpful-key)
(global-set-key (kbd "C-h x") 'helpful-command)

(require 'git-timemachine)
(global-set-key (kbd "C-c t") 'git-timemachine)

(require 'compile)
(global-set-key (kbd "C-c c") #'compile)

(provide 'misc)
