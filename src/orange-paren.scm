(include "./orange-paren-error.scm")
(include "./orange-paren-colors.scm")
(include "./orange-paren-server.scm")

(define-library (color-paren orange-paren)
   (import
     (scheme base)
     (scheme eval)
     (scheme repl)
     (scheme write)
     (scheme read)
     (scheme process-context)
     (srfi 18);TODO:optional
     (color-paren orange-paren colors)
     (color-paren orange-paren error)
     (color-paren orange-paren server))
   (export orange-paren/run)
   (begin

     (define %REPL-SETTINGS
       `((prompt
           ,(string-append
               (orange-paren-colors/front-256string 172)
               "orange-paren> "
               orange-paren-colors/reset-color))
         (*3 ())
         (*2 ())
         (*1 ())))

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

     (define (%server-start)
       (let ((s (color-paren-orange-paren/server "0")))))

     (define (%orange-paren-run  config)
       (call/cc
         (lambda (break)
          (let* ((env (interaction-environment))
                 (env-id 1)
                 (env-manager (list (list 0 env))))
            ;(%server-start)
            (%set-orange-paren-settings!
              env
              (current-input-port)
              '(prompt *3 *2 *1))
            (let loop ()
               (display (%ref-prompt env))
               (flush-output-port)
               (let* ((input* (read))
                      (import-flag
                        (and (list? input*)
                             (not (null? input*))
                             (eq? (car input*) 'import)
                             (cdr input*)))
                      (input
                        (if import-flag (if #f #t) input*)))
                 (when (eof-object? input)
                  (break))

                 (when import-flag
                   (set! env (apply environment import-flag))
                   (%set-orange-paren-settings!
                     env
                     (current-input-port)
                     '(prompt *3 *2 *1))
                   (set! env-manager (cons (list env-id  env) env-manager))
                   (set! env-id (+ 1 env-id)))

                 (let ((r '()))
                   (call/cc
                     (lambda (repl-error-break)
                       (with-exception-handler
                         (lambda (handler)
                             (orange-paren-error-report handler)
                             (set! r handler)
                             (repl-error-break #f ))
                         (lambda ()
                             (set! r (eval input env))))))
                    (cond
                      ((error-object? r))
                      (else
                       (display r)(newline)
                       (%save-return-value! input r env)))
                    (loop)))))))
       (exit))

         (define (orange-paren/run . config)
            (thread-start!
               (make-thread
                   (lambda ()
                     (%orange-paren-run config))))
            (%server-start))))

(import (scheme base)
        (color-paren orange-paren))

(orange-paren/run)
