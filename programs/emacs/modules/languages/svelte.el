(require 'svelte-mode)
(require 'lsp-mode)
(require 'company)
(require 'flycheck)
(require 'smartparens)

(setq lsp-svelte-plugin-typescript-enable t)
(setq lsp-svelte-plugin-css-enable t)

(add-hook 'svelte-mode-hook
          (lambda ()
            (lsp-deferred)
            (company-mode)
            (flycheck-mode)
            (smartparens-mode)
            (setq-local company-backends '(company-capf))))

(require 'prettier-js)
(add-hook 'svelte-mode-hook #'prettier-js-mode)

(provide 'svelte)
