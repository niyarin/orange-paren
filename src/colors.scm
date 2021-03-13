(define-library (orange-paren colors)
  (import (scheme base))
  (export string-256 reset-color)
  (begin
    (define (string-256 number)
      (string-append (string #\escape) "[38;5;" (number->string number) "m"))

    (define (reset-color)
      (string-append (string #\escape) "[0m"))))
