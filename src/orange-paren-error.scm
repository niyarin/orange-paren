(define-library (color-paren orange-paren error)
   (cond-expand 
     (gauche
       (import (scheme base)
               (gauche base))

       (begin
         (define orange-paren-error-report  report-error)))
     (else
       (import (scheme base)(scheme write))
       (begin
         (define (orange-paren-error-report err-object)
           (display 
            (error-object-message r))(newline)
           (display 
            (error-object-irritants r))(newline)))))
   (export orange-paren-error-report)
   (begin
     ))

