(define-library (orange-paren repl)
  (import (scheme base) (scheme eval) (scheme repl))
  (export make-default-env eval!)
  (begin
    (define-record-type <repl-env>
      (%make-repl-env scm-env)
      %repl-env?
      (scm-env %repl-env-scm-env %repl-env-set-scm-env!))

    (define (make-default-env)
      (let ((eval-env (interaction-environment)))
        (%make-repl-env eval-env)))

    (define (eval! expression repl-env)
      (let ((eval-env (%repl-env-scm-env repl-env)))
        (eval expression eval-env)))))
