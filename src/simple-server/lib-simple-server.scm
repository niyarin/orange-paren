(define-library (lib-simple-server)
   (import (scheme base)
           (srfi 18);multi thread
           (srfi 106);socket
           (scheme write)
           (scheme read))
   (export echo-listener make-simple-server simple-server?  ref-server-socket simple-server-start)
   (begin
     (define (echo-listener input-port output-port)
       (let loop ()
         (let ((c (read-u8 input-port)))
           (unless (eof-object? c)
              (display (integer->char c))
              (flush-output-port)
              (loop)))))

     (define (%listen listener socket)
       (let ((input-port (socket-input-port socket))
             (output-port (socket-output-port socket)))
         (listener input-port output-port)))

     (define-record-type <simple-server>
        (%make-simple-server listener server-socket)
        simple-server?
        (listener ref-listener)
        (server-socket ref-server-socket))

     (define (make-simple-server listener port)
       (let ((server-socket (make-server-socket port)))
         (%make-simple-server listener server-socket)))

     (define (simple-server-start simple-server)
       (unless (simple-server? simple-server) (error "Error simple-server required." simple-server))
       (let ((server-socket (ref-server-socket simple-server))
             (listener (ref-listener simple-server)))
         (let loop ()
           (let* ((accepted-socket (socket-accept server-socket))
                  (thread (make-thread (lambda () (%listen listener accepted-socket)))))
                 (thread-start! thread)
                 (loop)))))))
