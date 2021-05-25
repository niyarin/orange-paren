(define-library (orange-paren repl-eval)
  (import (scheme base) (scheme eval) (scheme repl) (scheme write) (srfi 18))
  (export make-default-env eval!)
  (begin
    (define-record-type <repl-env>
      (%make-repl-env scm-env mutex)
      %repl-env?
      (scm-env %repl-env-scm-env %repl-env-set-scm-env!)
      (mutex %repl-mutex %repl-mutex-set!))

    (define (make-default-env)
      (let ((eval-env (interaction-environment))
            (mutex (make-mutex)))
        (%make-repl-env eval-env mutex)))

    (define (%import-expression? expression)
      (and (list? expression)
           (eq? (car expression) 'import)))

    (define (eval! expression repl-env)
      (call-with-current-continuation
         (lambda (break)
            (with-exception-handler
              (lambda (err-object) (flush-output-port)(break err-object))
              (lambda ()
                (if (%import-expression? expression)
                  (let ((new-env (apply environment (cdr expression))))
                    (%repl-env-set-scm-env! repl-env new-env)
                    #t)
                  (let ((eval-env (%repl-env-scm-env repl-env))
                        (mutex (%repl-mutex repl-env))
                        (res '()))
                    (mutex-lock! mutex)
                    (set! res (eval expression eval-env))
                    (mutex-unlock! mutex)
                    res)))))))))
