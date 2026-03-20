(use-package ranger
  :ensure t
  :after hydra
  :init
  (setq ranger-override-dired 'ranger)
  :config
  (global-set-key (kbd "C-c f r") 'ranger))

(provide 'ranger-conf)
