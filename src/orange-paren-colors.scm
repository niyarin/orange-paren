(define-library (color-paren orange-paren colors)
   (import (scheme base))
   (export orange-paren-colors-front-256string
           orange-paren-colors-reset-color)
   (begin
      (define (orange-paren-colors-front-256string num)
         (string-append
           "\x1b[38;5;"
           (number->string num)
           "m"))
      (define orange-paren-colors-reset-color
        "\x1b[0m")
     ))
