(include "./simple-server/lib-simple-server.scm")
(include "./orange-paren/repl-eval.scm")
(include "./orange-paren/args.scm")
(include "./orange-paren/middleware.scm")

(import (scheme base) (scheme write) (scheme read)
        (scheme eval) (scheme process-context) (scheme file)
        (srfi 18) (srfi 106)
        (prefix (orange-paren repl-eval) orepl-eval/)
        (prefix (orange-paren args) oparen-args/)
        (prefix (orange-paren middleware) omiddleware/)
        (lib-simple-server))

(define (make-nrepl-listener middleware repl-env)
  (lambda (input-port output-port)
    (let loop ()
       (let ((obj (read input-port)))
         (unless (eof-object? obj)
            (call/cc
              (lambda (break)
                (with-exception-handler
                  (lambda (error-object)
                    (display (string-append "ERROR:"
                                            (error-object-message error-object))
                             output-port)
                    (display " " output-port)
                    (display (error-object-irritants error-object) output-port)
                    (write-char (integer->char 4) output-port)
                    (flush-output-port output-port)
                    (break "break"))
                  (lambda () (middleware obj repl-env output-port)))))
              (loop))))))

(define (my-repl repl-env)
  (let loop ()
    (display ">")(flush-output-port)
    (let loop-internal ()
            (unless (u8-ready? (current-input-port))
              (thread-sleep! 0.0001)
              (loop-internal)))
    (let ((input (read)))
      (if (eof-object? input)
        (begin (%oparen-halt) (exit 0))
        (begin
          (let ((res (orepl-eval/eval! input repl-env)))
            (for-each (lambda (x) (display x)(newline))
                      res))
          (flush-output-port)
          (loop))))))

(define (my-repl-start env)
  (thread-start! (make-thread (lambda () (my-repl env)))))

(define options (oparen-args/arg-parse (cdr (command-line))))

(define (%make-port-file port-string)
  (unless (string=? port-string "0")
    (call-with-output-file ".oparen-port"
        (lambda (output-port)
          (write-string port-string output-port)))))

(define (%delete-port-file)
  (when (file-exists? ".oparen-port")
    (delete-file ".oparen-port")))

(define (%oparen-halt)
  (%delete-port-file))

(let* ((repl-env (orepl-eval/make-default-env))
       (middlewares (omiddleware/default-middleware (lambda (x) x)))
       (listener (make-nrepl-listener middlewares repl-env)))
  (call-with-simple-server
    (make-simple-server listener (cdr (assq  'port options)))
    (lambda (my-server)
      (dynamic-wind
        (lambda ()
          (%delete-port-file)
          (%make-port-file (cdr (assq  'port options))))
        (lambda ()
          (display "start nrepl ...")(newline)
          (display "soclet:")(display (ref-server-socket my-server))(newline)(flush-output-port)
          (my-repl-start repl-env)
          (simple-server-start my-server))
        (lambda () (%oparen-halt))))))
