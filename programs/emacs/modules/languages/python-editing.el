(require 'company)
(require 'flycheck)
(require 'smartparens)
(require 'lsp-mode)

(setq flycheck-python-flake8-executable "flake8")

;; Configure lsp-mode
(setq lsp-keymap-prefix "C-c C-l")
(setq lsp-enable-snippet nil)  ; Disable snippets if you don't use yasnippet

(add-hook 'python-mode-hook
          (lambda ()
            (lsp-deferred)  ; Start LSP automatically
            (company-mode)
            (flycheck-mode)
            (smartparens-mode)
            (setq-local company-backends '(company-capf))
            (setq indent-tabs-mode nil
                  tab-width 4)))

(provide 'python-editing)

