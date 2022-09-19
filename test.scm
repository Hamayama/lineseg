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

(test* "lineseg-make-1" '((1 2)) (segs (mk '((1 2)))))
(test* "lineseg-make-2" '((1 3)) (segs (mk '((1 2) (2 3)))))
(test* "lineseg-make-3" '((1 4)) (segs (mk '((3 4) (2 3) (1 2)))))
(test* "lineseg-make-4" '((1 3)) (segs (mk '((1 2) (2 2) (2 3)))))
(test* "lineseg-make-5" '((1 1) (2 2) (3 3)) (segs (mk '((1 1) (2 2) (3 3)))))
(test* "lineseg-make-6" '((1.1 3.1)) (segs (mk '((1.1 2.1) (2.1 3.1)))))
(test* "lineseg-make-7" '((-2 2)) (segs (mk '((-2 -1) (-1 1) (1 2)))))
(test* "lineseg-make-8" (test-error <error>) (segs (mk '((2 1)))))
(test* "lineseg-make-9" (test-error <error>) (segs (mk '((1 2) (3.00001 3.0)))))

(test* "lineseg-length-1" 1   (lineseg-length (mk '((1 2)))))
(test* "lineseg-length-2" 2   (lineseg-length (mk '((1 2) (3 4)))))
(test* "lineseg-length-3" 2.2 (lineseg-length (mk '((1.2 2.3) (3.4 4.5)))))

(test* "lineseg-segs-1" '((1 2)) (segs (mk '((1 2)))))

(test* "lineseg-contains?-1" #t (lineseg-contains? (mk '((1 2))) 1))
(test* "lineseg-contains?-2" #t (lineseg-contains? (mk '((1 2))) 2))
(test* "lineseg-contains?-3" #t (lineseg-contains? (mk '((1 2) (4 5) (7 8))) 1))
(test* "lineseg-contains?-4" #f (lineseg-contains? (mk '((1 2) (4 5) (7 8))) 3))
(test* "lineseg-contains?-5" #f (lineseg-contains? (mk '((1 2) (4 5) (7 8))) 6))
(test* "lineseg-contains?-6" #t (lineseg-contains? (mk '((1 2) (4 5) (7 8))) 7))

(define lineseg-1 (mk '((1 2))))
(define lineseg-2 (lineseg-copy lineseg-1))
(slot-set! lineseg-1 'segs '((3 4)))
(test* "lineseg-copy-1" '((3 4)) (segs lineseg-1))
(test* "lineseg-copy-2" '((1 2)) (segs lineseg-2))

(test* "lineseg-intersect-1"
       '((2 3) (4 5))
       (segs (lineseg-intersect (mk '((1 3) (4 6))) (mk '((2 5))))))
(test* "lineseg-intersect-2"
       '((5 6))
       (segs (lineseg-intersect (mk '((1 3) (4 6))) (mk '((2 6))) (mk '((5 6))))))
(test* "lineseg-intersect-3"
       '()
       (segs (lineseg-intersect (mk '((3 6))) (mk '((7 8))))))
(test* "lineseg-intersect-4"
       '((5 6))
       (segs (lineseg-intersect (mk '((3 6))) (mk '((5 7))))))
(test* "lineseg-intersect-5"
       '((4 5))
       (segs (lineseg-intersect (mk '((3 6))) (mk '((4 5))))))
(test* "lineseg-intersect-6"
       '((3 4))
       (segs (lineseg-intersect (mk '((3 6))) (mk '((2 4))))))
(test* "lineseg-intersect-7"
       '()
       (segs (lineseg-intersect (mk '((3 6))) (mk '((1 2))))))
(test* "lineseg-intersect-8"
       '((3 6))
       (segs (lineseg-intersect (mk '((3 6))) (mk '((1 8))))))
(test* "lineseg-intersect-9"
       '()
       (segs (lineseg-intersect (mk '((1 1))) (mk '((2 2))))))

(test* "lineseg-union-1"
       '((1 2) (10 15))
       (segs (lineseg-union (mk '((1 2))) (mk '((10 15))))))
(test* "lineseg-union-2"
       '((1 5) (10 15))
       (segs (lineseg-union (mk '((1 2))) (mk '((10 15))) (mk '((2 5))))))
(test* "lineseg-union-3"
       '((3 6) (7 8))
       (segs (lineseg-union (mk '((3 6))) (mk '((7 8))))))
(test* "lineseg-union-4"
       '((3 7))
       (segs (lineseg-union (mk '((3 6))) (mk '((5 7))))))
(test* "lineseg-union-5"
       '((3 6))
       (segs (lineseg-union (mk '((3 6))) (mk '((4 5))))))
(test* "lineseg-union-6"
       '((2 6))
       (segs (lineseg-union (mk '((3 6))) (mk '((2 4))))))
(test* "lineseg-union-7"
       '((1 2) (3 6))
       (segs (lineseg-union (mk '((3 6))) (mk '((1 2))))))
(test* "lineseg-union-8"
       '((1 8))
       (segs (lineseg-union (mk '((3 6))) (mk '((1 8))))))
(test* "lineseg-union-9"
       '((1 1) (2 2))
       (segs (lineseg-union (mk '((1 1))) (mk '((2 2))))))

(test* "lineseg-subtract-1"
       '((1 2) (5 7))
       (segs (lineseg-subtract (mk '((1 3) (4 7))) (mk '((2 5))))))
(test* "lineseg-subtract-2"
       '((1 2) (5 6))
       (segs (lineseg-subtract (mk '((1 3) (4 7))) (mk '((2 5))) (mk '((6 7))))))
(test* "lineseg-subtract-3"
       '((3 6))
       (segs (lineseg-subtract (mk '((3 6))) (mk '((7 8))))))
(test* "lineseg-subtract-4"
       '((3 5))
       (segs (lineseg-subtract (mk '((3 6))) (mk '((5 7))))))
(test* "lineseg-subtract-5"
       '((3 4) (5 6))
       (segs (lineseg-subtract (mk '((3 6))) (mk '((4 5))))))
(test* "lineseg-subtract-6"
       '((4 6))
       (segs (lineseg-subtract (mk '((3 6))) (mk '((2 4))))))
(test* "lineseg-subtract-7"
       '((3 6))
       (segs (lineseg-subtract (mk '((3 6))) (mk '((1 2))))))
(test* "lineseg-subtract-8"
       '()
       (segs (lineseg-subtract (mk '((3 6))) (mk '((1 8))))))
(test* "lineseg-subtract-9"
       '((1 1))
       (segs (lineseg-subtract (mk '((1 1))) (mk '((2 2))))))
(test* "lineseg-subtract-10"
       '((3 4) (5 6))
       (segs (lineseg-subtract (mk '((1 2) (3 4) (5 6))) (mk '((1 2))))))
(test* "lineseg-subtract-11"
       '((1 2) (3 5) (6 10))
       (segs (lineseg-subtract (mk '((1 10))) (mk '((2 3) (5 6))))))
(test* "lineseg-subtract-12"
       '((1 2) (3 5) (6 7) (8 10))
       (segs (lineseg-subtract (mk '((1 10))) (mk '((2 3) (5 6) (7 8))))))
(test* "lineseg-subtract-13"
       '((1 2) (7 8))
       (segs (lineseg-subtract (mk '((1 3) (6 8))) (mk '((2 7))))))
(test* "lineseg-subtract-14"
       '((1 2) (7 8))
       (segs (lineseg-subtract (mk '((1 3) (6 8))) (mk '((2 4) (5 7))))))

;; summary
(format (current-error-port) "~%~a" ((with-module gauche.test format-summary)))

(test-end)

