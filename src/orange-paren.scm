(define-library (color-paren orange-paren)
   (import 
     (scheme base)
     (scheme eval)
     (scheme repl)
     (scheme write)
     (scheme read))
   (export orange-paren-run)
   (begin 
     (define (orange-paren-run . config)
       (call/cc
         (lambda (break)
          (let ((env (interaction-environment)))
            (let loop ()
               (display ">>")
               (flush-output-port)
               (let ((input (read)))
                 (when (eof-object? input)
                  (break))
                  
                 (let ((r (eval input env)))
                    (display r)(newline)
                    (loop))
               ))))))
     ))

(import (scheme base) 
        (color-paren orange-paren))

(orange-paren-run)
