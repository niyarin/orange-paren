(import (scheme base) (scheme read) (scheme write) (srfi 106))

(define address "localhost")
(define port "48293")

(define (%obj->string obj)
  (let ((output-port (open-output-string)))
    (write obj output-port)
    (write-string "\n" output-port)
    (get-output-string output-port)))

(define (%obj->utf8 obj) (string->utf8 (%obj->string obj)))

(define (%read input-port)
  (let loop ()
     (let ((c (read-u8 input-port)))
       (unless (or (eof-object? c) (= c 4))
          (display (integer->char c))
          (flush-output-port)
          (loop)))))

(let* ((client-socket (make-client-socket address port))
       (input-port (socket-input-port client-socket)))
    (let loop ()
      (display ">")(flush-output-port)
      (let ((input (read)))
        (socket-send client-socket (%obj->utf8 input))
        (%read input-port)
        (loop))))
