(global-set-key (kbd "C-c d") 'avy-goto-char-timer)
(global-set-key (kbd "C-c C-j") 'avy-goto-char-2)
(global-set-key (kbd "C-c j") 'avy-goto-word-0)
(global-set-key (kbd "C-c l") 'avy-goto-line)
(setq avy-timeout-seconds 0.5)

(with-eval-after-load 'python
  (define-key python-mode-map (kbd "M-<right>") #'treesit-forward-sexp)
  (define-key python-mode-map (kbd "M-<left>")  #'treesit-backward-sexp)
  (define-key python-mode-map (kbd "M-<down>")  #'treesit-end-of-defun)
  (define-key python-mode-map (kbd "M-<up>")    #'treesit-beginning-of-defun))

(global-set-key (kbd "M-o") 'ace-window)

(global-set-key (kbd "C-c b") 'sp-forward-sexp)
(global-set-key (kbd "C-c B") 'sp-backward-sexp)

(global-set-key (kbd "C-c m l") 'mc/edit-lines)
(global-set-key (kbd "C-c m n") 'mc/mark-next-like-this)
(global-set-key (kbd "C-c m p") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c m a") 'mc/mark-all-like-this)

(defun mc/mark-all-words-like-this-at-point ()
  (interactive)
  (let* ((bounds (or (bounds-of-thing-at-point 'symbol)
                     (bounds-of-thing-at-point 'word)))
         (text (when bounds
                 (buffer-substring-no-properties (car bounds) (cdr bounds)))))
    (if text
        (progn
          (goto-char (car bounds))
          (mc/mark-all-words-like-this)
          (message "Marked all instances of: %s" text))
      (message "No symbol at point"))))
(global-set-key (kbd "C-c m A") 'mc/mark-all-words-like-this-at-point)
(global-set-key (kbd "C-c e") 'er/expand-region)
(global-set-key (kbd "C-c w c") (lambda () (interactive) (other-window +1)))
(global-set-key (kbd "C-c w C") (lambda () (interactive) (other-window -1)))
(global-set-key (kbd "C-c w x") 'delete-window)
(global-set-key (kbd "C-c w b") 'windmove-left)
(global-set-key (kbd "C-c w n") 'windmove-down)
(global-set-key (kbd "C-c w f") 'windmove-right)
(global-set-key (kbd "C-c w p") 'windmove-up)

(use-package consult
  :ensure t
  :bind (
         ("C-x b" . consult-buffer)
         ("C-x 4 b" . consult-buffer-other-window)
         ("C-x 5 b" . consult-buffer-other-frame)
         ("M-g g" . consult-goto-line)
         ("M-g i" . consult-imenu)
         ("M-g o" . consult-outline)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s g" . consult-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s f" . consult-find)
         )
  :config
  (require 'embark-consult)
  )

(defun my/consult-ripgrep-project ()
  (interactive)
  (let ((default-directory (my/get-project-root)))
    (consult-ripgrep default-directory)))

(global-set-key (kbd "C-c g") 'my/consult-ripgrep-project)

(require 'vertico)
(vertico-mode)
(require 'vertico-directory)
(add-hook 'rfn-eshadow-update-overlay-hook #'vertico-directory-tidy)
(setq vertico-cycle t)

(provide 'navigation)
