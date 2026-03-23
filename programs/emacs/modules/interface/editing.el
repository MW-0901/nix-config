(setq-default indent-tabs-mode nil
              tab-width 4)

(show-paren-mode 1)

(require 'smartparens-config)
(smartparens-global-mode t)

(recentf-mode 1)
(setq recentf-max-menu-items 25
      recentf-max-saved-items 25)

(require 'undo-tree)
(global-undo-tree-mode)
(setq undo-tree-auto-save-history nil)

(require 'rainbow-delimiters)
(add-hook 'prog-mode-hook #'rainbow-delimiters-mode)

(require 'flycheck)
(global-flycheck-mode)

(provide 'editing)
