(require 'circe)

(setq circe-network-options
      '(("Libera Chat"
         :network "Libera.Chat"
         :nick "yournick"
         :channels ("#emacs" "#linux")
         :use-tls t)))

(provide 'circe-irc)
