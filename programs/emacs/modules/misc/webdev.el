;; Webdev: simple HTTP server for static files

(require 'simple-httpd)

;; Set default port
(setq httpd-port 8080)

(defun serve ()
  "Start a simple HTTP server in the current directory.
  The server will be accessible at http://localhost:8080"
  (interactive)
  (let ((dir default-directory))
    (setq httpd-root dir)
    (httpd-start)
    (message "Serving %s at http://localhost:%d" dir httpd-port)))

(defun serve-stop ()
  "Stop the HTTP server."
  (interactive)
  (httpd-stop)
  (message "HTTP server stopped."))

(provide 'webdev)
