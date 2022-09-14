;;
;; Test lineseg
;;

(add-load-path "." :relative)
(use gauche.test)

(test-start "lineseg")
(use lineseg)
(test-module 'lineseg)

(define mk   make-lineseg)
(define segs lineseg-segs)

(test-section "lineseg-function")

(test* "lineseg-length-1" 1   (lineseg-length (mk '((1 2)))))
(test* "lineseg-length-2" 2   (lineseg-length (mk '((1 2) (3 4)))))
(test* "lineseg-length-3" 2.2 (lineseg-length (mk '((1.2 2.3) (3.4 4.5)))))

(test* "lineseg-segs-1" '((1 2)) (segs (mk '((1 2)))))

(define lineseg-1 (mk '((1 2))))
(define lineseg-2 (lineseg-copy lineseg-1))
(slot-set! lineseg-1 'segs '((3 4)))
(test* "lineseg-copy-1" '((3 4)) (segs lineseg-1))
(test* "lineseg-copy-2" '((1 2)) (segs lineseg-2))

(test* "lineseg-intersect-1"
       '((2 3) (4 5))
       (segs (lineseg-intersect (mk '((1 3) (4 6))) (mk '((2 5))))))
(test* "lineseg-intersect-2"
       '()
       (segs (lineseg-intersect (mk '((3 6))) (mk '((7 8))))))
(test* "lineseg-intersect-3"
       '((5 6))
       (segs (lineseg-intersect (mk '((3 6))) (mk '((5 7))))))
(test* "lineseg-intersect-4"
       '((4 5))
       (segs (lineseg-intersect (mk '((3 6))) (mk '((4 5))))))
(test* "lineseg-intersect-5"
       '((3 4))
       (segs (lineseg-intersect (mk '((3 6))) (mk '((2 4))))))
(test* "lineseg-intersect-6"
       '()
       (segs (lineseg-intersect (mk '((3 6))) (mk '((1 2))))))
(test* "lineseg-intersect-7"
       '((3 6))
       (segs (lineseg-intersect (mk '((3 6))) (mk '((1 8))))))
(test* "lineseg-intersect-8"
       '()
       (segs (lineseg-intersect (mk '((1 1))) (mk '((2 2))))))

(test* "lineseg-union-1"
       '((1 5) (10 15))
       (segs (lineseg-union (mk '((1 2))) (mk '((10 15))) (mk '((2 5))))))
(test* "lineseg-union-2"
       '((3 6) (7 8))
       (segs (lineseg-union (mk '((3 6))) (mk '((7 8))))))
(test* "lineseg-union-3"
       '((3 7))
       (segs (lineseg-union (mk '((3 6))) (mk '((5 7))))))
(test* "lineseg-union-4"
       '((3 6))
       (segs (lineseg-union (mk '((3 6))) (mk '((4 5))))))
(test* "lineseg-union-5"
       '((2 6))
       (segs (lineseg-union (mk '((3 6))) (mk '((2 4))))))
(test* "lineseg-union-6"
       '((1 2) (3 6))
       (segs (lineseg-union (mk '((3 6))) (mk '((1 2))))))
(test* "lineseg-union-7"
       '((1 8))
       (segs (lineseg-union (mk '((3 6))) (mk '((1 8))))))
(test* "lineseg-union-8"
       '((1 1) (2 2))
       (segs (lineseg-union (mk '((1 1))) (mk '((2 2))))))

(test* "lineseg-subtract-1"
       '((1 2) (5 6))
       (segs (lineseg-subtract (mk '((1 3) (4 6))) (mk '((2 5))))))
(test* "lineseg-subtract-2"
       '((3 6))
       (segs (lineseg-subtract (mk '((3 6))) (mk '((7 8))))))
(test* "lineseg-subtract-3"
       '((3 5))
       (segs (lineseg-subtract (mk '((3 6))) (mk '((5 7))))))
(test* "lineseg-subtract-4"
       '((3 4) (5 6))
       (segs (lineseg-subtract (mk '((3 6))) (mk '((4 5))))))
(test* "lineseg-subtract-5"
       '((4 6))
       (segs (lineseg-subtract (mk '((3 6))) (mk '((2 4))))))
(test* "lineseg-subtract-6"
       '((3 6))
       (segs (lineseg-subtract (mk '((3 6))) (mk '((1 2))))))
(test* "lineseg-subtract-7"
       '()
       (segs (lineseg-subtract (mk '((3 6))) (mk '((1 8))))))
(test* "lineseg-subtract-8"
       '((1 1))
       (segs (lineseg-subtract (mk '((1 1))) (mk '((2 2))))))
(test* "lineseg-subtract-9"
       '((3 4) (5 6))
       (segs (lineseg-subtract (mk '((1 2) (3 4) (5 6))) (mk '((1 2))))))

;; summary
(format (current-error-port) "~%~a" ((with-module gauche.test format-summary)))

(test-end)

