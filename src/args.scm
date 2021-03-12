(define-library (orange-paren args)
    (import (scheme base) (scheme write))
    (export arg-parse)
    (begin
      (define (arg-parse args)
        (let loop ((args args)
                   (res '((port . "0"))))
          (cond
            ((null? args) res)
            ((and (equal? (car args) "--port") (not (null? (cdr args))))
             (loop (cddr args)
                   (cons (cons 'port (cadr args)) res)))
            (error "Invalid args."))))))
