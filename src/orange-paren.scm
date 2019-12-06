(include "./orange-paren-error.scm")

(define-library (color-paren orange-paren)
   (import 
     (scheme base)
     (scheme eval)
     (scheme repl)
     (scheme write)
     (scheme read)
     (color-paren orange-paren error))
   (export orange-paren-run)
   (begin 

     (define %REPL-SETTINGS
       '((prompt "orange-paren>")
         (*3 '())
         (*2 '())
         (*1 '())
         ))

     (define (%set-orange-paren-settings! env port setting-set)
       (for-each
         (lambda (sym)
           (let ((target
                    (cond
                      ((assv sym %REPL-SETTINGS)
                       => cadr)
                      (else '()))))
             (when target
               (eval `(define ,sym ,target) env))))
         setting-set))

     (define (%ref-prompt env)
         (eval 
           `(let ((p prompt ))
              (cond 
                ((procedure? p) (p))
                (else p)))
           env))
         
     (define (%save-return-value! input return-value env)
       (unless 
         (or (eval `(eq? *1 ,input) env)
             (eval `(eq? *2 ,input) env)
             (eval `(eq? *3 ,input) env))
          (eval '(set! *3 *2) env)
          (eval '(set! *2 *1) env)
          (eval `(set! *1 ',return-value) env)))

     (define (orange-paren-run . config)
       (call/cc
         (lambda (break)
          (let ((env (interaction-environment)))
            (%set-orange-paren-settings! env (current-input-port) '(prompt *3 *2 *1))
            (let loop ()
               (display (%ref-prompt env))
               (flush-output-port)
               (let ((input (read)))
                 (when (eof-object? input)
                  (break))
                  
                 (let ((r '()))
                   (call/cc 
                     (lambda (repl-error-break)
                       (with-exception-handler
                         (lambda (err-object)
                           (set! r err-object)
                           (repl-error-break #f ))
                         (lambda ()
                             (set! r
                                  (eval 
                                    `(call/cc 
                                       (lambda (repl-error-break)
                                         (with-exception-handler
                                           (lambda (err)
                                             (repl-error-break err))
                                           (lambda ()
                                             ,input))))
                                    env))))))

                    (cond 
                      ((error-object? r) 
                       (orange-paren-error-report r))
                      (else
                       (display r)(newline)
                       (%save-return-value! input r env)))
                    (loop))
               ))))))
     ))

(import (scheme base) 
        (color-paren orange-paren))

(orange-paren-run)
