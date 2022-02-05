(define-library (orange-paren middleware)
  (import (scheme base)
          (scheme write)
          (prefix (orange-paren repl-eval) orepl-eval/))
  (export default-middleware eval-middleware)
  (begin
    (define (%assq key als . def)
      (cond
        ((assq key als) => cadr)
        ((null? def) #f)
        (else (car def))))

    (define (%ref-op input)
      ;(%assq 'op input #f)
      (car input))

    (define (%run-eval code repl-env nport)
      (let ((res
              (parameterize ((current-output-port nport))
                (orepl-eval/eval! code repl-env))))
        (when (error-object? res) (error "EVAL-ERROR"))
        (for-each (lambda (x) (write x nport)
                              (newline nport))
                  res)
        (write-char (integer->char 4) nport)
        (flush-output-port nport)))

    (define (eval-middleware handler)
      (lambda (input repl-env nport)
        (if (eq? (%ref-op input) 'eval)
          (%run-eval (cadr input) repl-env nport)
          (handler input repl-env nport))))

    (define (default-middleware handler)
      (eval-middleware handler))))
