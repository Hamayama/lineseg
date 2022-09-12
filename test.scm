;;
;; Test lineseg
;;

(add-load-path "." :relative)
(use gauche.test)

(test-start "lineseg")
(use lineseg)
(test-module 'lineseg)

(define mk make-lineseg)

(test-section "lineseg-function")

(test* "lineseg-length-1" 1   (lineseg-length (mk '((1 2)))))
(test* "lineseg-length-1" 2   (lineseg-length (mk '((1 2) (3 4)))))
(test* "lineseg-length-1" 2.2 (lineseg-length (mk '((1.2 2.3) (3.4 4.5)))))

(define lineseg-1 (mk '((1 2))))
(define lineseg-2 (lineseg-copy lineseg-1))
(slot-set! lineseg-1 'segs '((3 4)))
(test* "lineseg-copy-1" '((3 4)) (slot-ref lineseg-1 'segs))
(test* "lineseg-copy-2" '((1 2)) (slot-ref lineseg-2 'segs))

(test* "lineseg-intersect-1"
       '((2 3) (4 5))
       (slot-ref (lineseg-intersect (mk '((1 3) (4 6))) (mk '((2 5)))) 'segs))

(test* "lineseg-union-1"
       '((1 5) (10 15))
       (slot-ref (lineseg-union (mk '((1 2))) (mk '((10 15))) (mk '((2 5))))
                 'segs))

(test* "lineseg-subtract-1"
       '((1 2) (5 6))
       (slot-ref (lineseg-subtract  (mk '((1 3) (4 6))) (mk '((2 5)))) 'segs))


;; summary
(format (current-error-port) "~%~a" ((with-module gauche.test format-summary)))

(test-end)

