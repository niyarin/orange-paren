(define-library (orange-paren repl-eval)
  (import (scheme base) (scheme eval) (scheme repl) (scheme write))
  (export make-default-env eval!)
  (begin
    (define-record-type <repl-env>
      (%make-repl-env scm-env)
      %repl-env?
      (scm-env %repl-env-scm-env %repl-env-set-scm-env!))

    (define (make-default-env)
      (let ((eval-env (interaction-environment)))
        (%make-repl-env eval-env)))

    (define (%import-expression? expression);;TODO:check library name
      (and (list? expression)
           (eq? (car expression) 'import)))

    (define (eval! expression repl-env)
      (call-with-current-continuation
         (lambda (break)
            (if (%import-expression? expression)
              (with-exception-handler
                (lambda (err-object) (break err-object))
                (lambda ()
                  (let ((new-env (apply environment (cdr expression))))
                    (%repl-env-set-scm-env! repl-env new-env)
                    'imported)))
              (let ((eval-env (%repl-env-scm-env repl-env)))
                (eval expression eval-env))))))))
