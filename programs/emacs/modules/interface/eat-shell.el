(require 'eat)
(require 'eshell)
(require 'em-cmpl)
(require 'em-prompt)
(require 'em-dirs)
(require 'em-alias)
(require 'em-hist)
(require 'magit)
(require 'company)
(require 'envrc)
(require 'pyvenv)

(eat-eshell-mode 1)
(eat-eshell-visual-command-mode 1)

(setq eat-enable-yank-to-terminal t)
(global-set-key (kbd "C-c H") 'eat)
(global-set-key (kbd "C-c h") 'eshell)

(add-hook 'eat-mode-hook
          (lambda ()
            (display-line-numbers-mode -1)
            (text-scale-set 2)))

(setq eshell-prefer-lisp-functions nil
      eshell-prefer-lisp-variables t
      eshell-highlight-prompt t
      eshell-history-size 10000
      eshell-save-history-on-exit t
      eshell-hist-ignoredups t)

(defun my/eshell-prompt ()
  (let ((git-branch (when (and (fboundp 'magit-get-current-branch)
                               (magit-get-current-branch))
                      (concat " ‹" (magit-get-current-branch) "›"))))
    (concat
     (propertize (abbreviate-file-name (eshell/pwd))
                 'face '(:foreground "#83a598"))
     (when git-branch
       (propertize git-branch
                   'face '(:foreground "#fe8019")))
     "\n"
     (propertize "$ "
                 'face '(:foreground "#b8bb26")))))

(setq eshell-prompt-function 'my/eshell-prompt
      eshell-prompt-regexp "^\\$ ")

(defun eshell/clear ()
  (interactive)
  (goto-char (point-max))
  (let ((inhibit-read-only t))
    (delete-region (point-min) (point-at-bol))))

(add-hook 'eshell-mode-hook
          (lambda ()
            (setq mode-line-format nil)
            (display-line-numbers-mode -1)
            (setq-local scroll-margin 0)
            (setq-local company-backends '(company-capf))
            (setq-local company-idle-delay 1.5)
            (setq-local company-minimum-prefix-length 1)
            (company-mode 1)
            (local-set-key (kbd "C-l") 'eshell/clear)
            (local-set-key (kbd "<up>") 'eshell-previous-input)
            (local-set-key (kbd "<down>") 'eshell-next-input)
            (local-set-key (kbd "M-p") 'eshell-previous-input)
            (local-set-key (kbd "M-n") 'eshell-next-input)
            (local-set-key (kbd "TAB") 'company-complete)
            (when (require 'eshell-z nil t)
              (require 'eshell-z))
            (when (require 'eshell-syntax-highlighting nil t)
              (eshell-syntax-highlighting-mode 1))))

(with-eval-after-load 'eshell
  (eshell/alias "ls" "eza $*")
  (eshell/alias "rebuild" "sudo nixos-rebuild switch --flake ~/config#nixos")
  (eshell/alias "e" "find-file $1"))

(envrc-global-mode)
(add-hook 'eshell-mode-hook (lambda () (envrc-mode 1)))

(defun my/eshell-auto-activate-venv ()
  (when-let ((venv-dir (or
                        (locate-dominating-file default-directory ".venv")
                        (locate-dominating-file default-directory "venv")
                        (locate-dominating-file default-directory ".virtualenv"))))
    (pyvenv-activate (expand-file-name
                      (or (and (file-exists-p (concat venv-dir ".venv"))
                               (concat venv-dir ".venv"))
                          (and (file-exists-p (concat venv-dir "venv"))
                               (concat venv-dir "venv"))
                          (concat venv-dir ".virtualenv"))))))

(add-hook 'eshell-directory-change-hook 'my/eshell-auto-activate-venv)

(add-hook 'eshell-directory-change-hook
          (lambda ()
            (if (file-remote-p default-directory)
                (eat-eshell-mode -1)
              (eat-eshell-mode 1))))

(provide 'eat-shell)
