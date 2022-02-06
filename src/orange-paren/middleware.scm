(define-library (orange-paren middleware)
  (import (scheme base)
          (scheme write)
          (scheme eval)
          (scheme list)
          (except (orange-paren hack-expressions) define)
          (prefix (orange-paren repl-eval) orepl-eval/))
  (export default-middleware eval-middleware get-procedure-positions)
  (begin
    (define (%assq key als . def)
      (cond
        ((assq key als) => cadr)
        ((null? def) #f)
        (else (car def))))

    (define (%ref-op input)
      ;(%assq 'op input #f)
      (car input))

    (define (%write-res objects nport)
        (for-each (lambda (x) (write x nport)
                              (newline nport))
                  objects)
        (write-char (integer->char 4) nport)
        (flush-output-port nport))

    (define (%run-eval code repl-env nport)
      (he/init)
      (let ((res
              (parameterize ((current-output-port nport))
                (orepl-eval/eval! code repl-env))))
        (when (error-object? res) (raise res))
        (%write-res res nport)))

    (define (eval-middleware handler)
      (lambda (input repl-env nport)
        (if (eq? (%ref-op input) 'eval)
          (%run-eval (cadr input) repl-env nport)
          (handler input repl-env nport))))

    (define (echo-middleware handler)
      (lambda (input repl-env nport)
        (write input)(newline)
        (handler input repl-env nport)))

    (define *procedure-positions* '());;期限設けたい

    (define (get-procedure-positions) *procedure-positions*)

    (define (record-position-middleware handler)
      (lambda (input repl-env nport)
        (when (eq? (%ref-op input) 'eval)
          (let ((code (cadr input))
                (filename (list-ref input 2))
                (line (list-ref input 3)))

            (when (and (> (length code) 2)
                       (eq? (car code) 'define)
                       (list? (cadr code)))
              (set! *procedure-positions*
                    (cons (list (car (cadr code)) filename line)
                          *procedure-positions*)))))
        (handler input repl-env nport)))

    (define-syntax nest%
      (syntax-rules ()
        ((_ x) x)
        ((_ (ope _) next ...)
         (ope (nest% next ...)))))

    (define (import-trap! code repl-env nport)
      (let ((new-env (apply environment (cdr code))))
        (orepl-eval/repl-env-set-scm-env! repl-env new-env)
        (%write-res '(#t) nport)))

    (define (import-trap-middleware handler)
      (lambda (input repl-env nport)
        (if (and (eq? (%ref-op input) 'eval)
                 (eq? (car (cadr input)) 'import))
          (import-trap! (cadr input) repl-env nport)
          (handler input repl-env nport))))

    (define (%rename-libnames lib-names)
      (let loop ((names lib-names))
        (cond
          ((null? names) '())
          ((equal? (car names) '(scheme base));;TODO: support for rename, prefix, except, only
           (cons* '(except (scheme base) define)
                  '(orange-paren hack-expressions)
                  (loop (cdr names))))
          (else (cons (car names) (loop (cdr names)))))))

    (define (import-trap-hack! code repl-env nport)
      (let* ((lib-names (cdr code))
             (new-env (apply environment (%rename-libnames lib-names))))
        (orepl-eval/repl-env-set-scm-env! repl-env new-env)
        (%write-res '(#t) nport)))

    (define (import-trap-hack-middleware handler)
      (lambda (input repl-env nport)
        (if (and (eq? (%ref-op input) 'eval)
                 (eq? (car (cadr input)) 'import))
          (import-trap-hack! (cadr input) repl-env nport)
          (handler input repl-env nport))))

    (define (default-middleware handler)
      (nest% (import-trap-hack-middleware _);;import-trap
             (record-position-middleware _)
             (eval-middleware _)
             handler))))
