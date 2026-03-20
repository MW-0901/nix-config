(require 'elfeed)

(declare-function elfeed-show-visit "elfeed-show")
(declare-function elfeed-search-browse-url "elfeed-search")
(declare-function shr-browse-url "shr")
(defvar elfeed-show-mode-map)
(defvar elfeed-search-mode-map)

(setq elfeed-db-directory "~/.elfeed")
(global-set-key (kbd "C-c n") 'elfeed)

(setq elfeed-feeds
      '(
        ("https://news.ycombinator.com/rss" tech hn)
        ("https://www.reddit.com/r/nixos/.rss" nix reddit)
        ("https://www.reddit.com/r/emacs/.rss" emacs reddit)
        ))

(add-hook 'elfeed-search-mode-hook
          (lambda ()
            (text-scale-set 2)))

(add-hook 'elfeed-show-mode-hook
          (lambda ()
            (text-scale-set 2)))

(defun my/reddit-to-old (url)
  "Convert Reddit URLs to old.reddit.com"
  (if (string-match "\\(https?://\\)\\(www\\.\\)?reddit\\.com" url)
      (replace-regexp-in-string "\\(https?://\\)\\(www\\.\\)?reddit\\.com" 
                                "\\1old.reddit.com" 
                                url)
    url))

(with-eval-after-load 'elfeed
  (define-key elfeed-search-mode-map (kbd "R") 'elfeed-search-fetch)
  (define-key elfeed-search-mode-map (kbd "g") 'elfeed-search-update--force)
  (define-key elfeed-search-mode-map (kbd "q") 'elfeed-search-quit-window)
  
  (define-key elfeed-search-mode-map (kbd "b")
              (lambda () (interactive)
                (let ((browse-url-browser-function 'eww-browse-url))
                  (elfeed-search-browse-url))))
  
  (define-key elfeed-show-mode-map (kbd "b")
              (lambda () (interactive)
                (let ((browse-url-browser-function 'eww-browse-url)
                      (url (get-text-property (point) 'help-echo)))
                  (if url
                      (browse-url (my/reddit-to-old url))
                    (elfeed-show-visit)))))
  
  (define-key elfeed-show-mode-map (kbd "RET")
              (lambda () (interactive)
                (let ((browse-url-browser-function 'eww-browse-url))
                  (shr-browse-url)))))

(provide 'news)
