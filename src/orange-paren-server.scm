(define-library (color-paren orange-paren server)
   (import
     (scheme base)
     (scheme write)
     (scheme read)
     (srfi 18);multi thread
     (srfi 106);socket
     )
   (export color-paren-orange-paren/server)
   (begin
      (define (%read port);read-while input is not 13(#\return).
         (let ((output-port (open-output-string)))
           (let loop ()
             (display port)(newline)
              (let ((c (read-u8 port)))
                (display c)(newline)
                (if (= c 13)
                  (begin
                     (read-u8 port)
                     (get-output-string output-port))
                  (begin
                    (write-char (integer->char c) output-port)
                    (loop)))))))

      (define (%api s-expression)
        )

      (define (%listen socket opt)
         (let  ((in-port (socket-input-port socket))
                (out-port (socket-output-port socket)))
           (guard
             (e (#t #f)(else #f))
             (let ((s-expression (%read in-port)))
               (display "ECHO:")(display s-expression)(newline)
               (%api s-expression)))))

      (define (color-paren-orange-paren/server port . opt)
        (let ((server-socket (make-server-socket port)))
          (display server-socket)(newline)
          (let loop ()
            (let* ((socket (socket-accept server-socket))
                   (thread (make-thread
                              (lambda ()
                                (%listen socket opt)))))
              (thread-start!
                thread)
              (loop)))))
     ))
