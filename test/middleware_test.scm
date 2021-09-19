(include "../src/repl-eval.scm")
(include "../src/middleware.scm")

(import (scheme base)
        (scheme write)
        (srfi 64)
        (prefix (orange-paren repl-eval) orepl-eval/)
        (prefix (orange-paren middleware) omware/))


(test-begin "eval-middleware-test")
(let ((repl-env (orepl-eval/make-default-env)))
  (test-equal
    ((omware/eval-middleware (lambda x x))
            '((op eval)
              (code (cons 1 2)))
            repl-env)
    '((success #t)
      (res ((1 . 2))))))
(test-end "eval-middleware-test")

