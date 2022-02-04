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
      (%assq 'op input #f))

    (define (%succress-resp resp)
      `((success #t)
        (res ,resp)))

    (define (%run-eval code repl-env)
      (let ((res (orepl-eval/eval! code repl-env)))
        (%succress-resp res)))

    (define (eval-middleware handler)
      (lambda (input repl-env)
        (if (eq? (%ref-op input) 'eval)
          (%run-eval (%assq 'code input) repl-env)
          (handler input repl-env))))

    (define (default-middleware handler)
      (eval-middleware handler))))
