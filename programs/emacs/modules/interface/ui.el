(require 'doom-themes)
(setq doom-themes-enable-bold t
      doom-themes-enable-italic t)
(load-theme 'doom-gruvbox t)
(doom-themes-visual-bell-config)
(doom-themes-org-config)

(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode t)

(setq display-buffer-alist
      '(("\\*compilation\\*"
         (display-buffer-reuse-window display-buffer-at-bottom)
         (reusable-frames . visible)
         (window-height . 0.25))))
(setq doom-themes-enable-bold t
      doom-themes-enable-italic t)
(when (not (display-graphic-p))
  (when (getenv "COLORTERM")
    (setq term-termcap-format t)))

(provide 'ui)
