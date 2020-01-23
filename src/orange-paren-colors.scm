(define-library (color-paren orange-paren colors)
   (import (scheme base))
   (export orange-paren-colors/front-256string
           orange-paren-colors/reset-color)
   (begin
      (define (orange-paren-colors/front-256string num)
         (string-append
           (string #\escape)
           "[38;5;"
           (number->string num)
           "m"))
      (define orange-paren-colors/reset-color
        (string-append
           (string #\escape)
           "[0m"))))
