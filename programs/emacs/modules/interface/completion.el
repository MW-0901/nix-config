(require 'company)
(global-company-mode)
(setq company-idle-delay 0.1
      company-minimum-prefix-length 1)
(setq company-global-modes '(not eshell-mode minibuffer-mode minibuffer-inactive-mode))
(require 'embark)
(global-set-key (kbd "C-;") 'embark-act)
(global-set-key (kbd "C-h B") 'embark-bindings)

(marginalia-mode)
(provide 'completion)
