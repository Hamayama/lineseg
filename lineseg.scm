;; -*- coding: utf-8 -*-
;;
;; lineseg.scm
;; 2022-9-19 v1.05
;;
;; ＜内容＞
;;   Gauche で、数直線上の線分を扱うためのモジュールです。
;;
;;   詳細については、以下のページを参照ください。
;;   https://github.com/Hamayama/lineseg
;;
(define-module lineseg
  (export
    make-lineseg
    lineseg-copy
    lineseg-length
    lineseg-segs
    lineseg-contains?
    lineseg-intersect
    lineseg-union
    lineseg-subtract
    ))
(select-module lineseg)

;; 線分クラス
(define-class <lineseg> ()
  ((segs       :init-value '()) ; 線分の集合 ((start1 end1) (start2 end2) ...)
   (comparator :init-value default-comparator) ; 比較器
   (add-func   :init-value +)   ; 加算関数
   (sub-func   :init-value -)   ; 減算関数
   ))

;; 線分のインスタンス生成
;;
;;   例. (make-lineseg '((1 2)))
;;
(define (make-lineseg segs :key (comparator default-comparator) (add-func +) (sub-func -))
  (define lineseg1 (make <lineseg>))
  ;; 個々の線分の範囲をチェック
  (for-each
   (lambda (seg1)
     (let ((start (list-ref seg1 0))
           (end   (list-ref seg1 1)))
       (when (>? comparator start end)
         (error "segment must be start <= end:" start end))))
   segs)
  ;; データを設定
  (slot-set! lineseg1 'segs       segs)
  (slot-set! lineseg1 'comparator comparator)
  (slot-set! lineseg1 'add-func   add-func)
  (slot-set! lineseg1 'sub-func   sub-func)
  ;; 線分の正規化
  (%lineseg-normalize! lineseg1))

;; 線分のコピー
(define (lineseg-copy lineseg1)
  (define lineseg2 (make <lineseg>))
  (define segs1    (slot-ref lineseg1 'segs))
  (define segs2
    ;; 個々の線分をコピーして追加
    (fold
     (lambda (seg1 segs2-temp)
       (push! segs2-temp (list-copy seg1))
       segs2-temp)
     '()
     segs1))
  ;; データを設定
  (slot-set! lineseg2 'segs       (reverse segs2))
  (slot-set! lineseg2 'comparator (slot-ref lineseg1 'comparator))
  (slot-set! lineseg2 'add-func   (slot-ref lineseg1 'add-func))
  (slot-set! lineseg2 'sub-func   (slot-ref lineseg1 'sub-func))
  lineseg2)

;; 線分の長さを取得
(define (lineseg-length lineseg1)
  (define add-func (slot-ref lineseg1 'add-func))
  (define sub-func (slot-ref lineseg1 'sub-func))
  (define segs1    (slot-ref lineseg1 'segs))
  ;; 個々の線分の長さを加算
  (fold
   (lambda (seg1 result-len)
     (let* ((start (list-ref seg1 0))
            (end   (list-ref seg1 1))
            (len1  (sub-func end start)))
       (if result-len
         (add-func result-len len1)
         len1)))
   #f
   segs1))

;; 線分の集合を取得
(define (lineseg-segs lineseg1)
  (slot-ref lineseg1 'segs))

;; 線分に値が含まれるか?
(define (lineseg-contains? lineseg1 val)
  (define cmpr  (slot-ref lineseg1 'comparator))
  (define segs1 (slot-ref lineseg1 'segs))
  (any
   (lambda (seg1)
     (let ((start (list-ref seg1 0))
           (end   (list-ref seg1 1)))
       (and (>=? cmpr val start)
            (<=? cmpr val end))))
   segs1))


;; 線分の積集合を取得
(define (lineseg-intersect :rest lineseg-list)
  ;; 2個の線分の積集合を取得して、lineseg1 にセットする(内部処理用)
  (define (%intersect! lineseg1 lineseg2)
    (define cmpr      (slot-ref lineseg1 'comparator))
    (define segs2     (slot-ref lineseg2 'segs))
    (define index2    0)
    (define segs1-new
      (fold
       (lambda (seg1 segs1-temp)
         (let loop ()
           (when (< index2 (length segs2))
             (let* ((seg2       (list-ref segs2 index2))
                    (seg1-start (list-ref seg1 0))
                    (seg1-end   (list-ref seg1 1))
                    (seg2-start (list-ref seg2 0))
                    (seg2-end   (list-ref seg2 1)))
               ;; 共通部分を抽出する
               (when (and (<? cmpr seg1-start seg2-end)
                          (<? cmpr seg2-start seg1-end))
                 (push! segs1-temp
                        (list (if (>=? cmpr seg1-start seg2-start) seg1-start seg2-start)
                              (if (<=? cmpr seg1-end   seg2-end)   seg1-end   seg2-end))))
               ;; まだ共通部分がある可能性があるなら、繰り返す
               (when (>? cmpr seg1-end seg2-end)
                 (inc! index2)
                 (loop))
               )))
         segs1-temp)
       '()
       (slot-ref lineseg1 'segs)))
    (slot-set! lineseg1 'segs (reverse segs1-new)))

  ;; 線分の積集合を取得
  (if (null? lineseg-list)
    #f
    (let ((lineseg1 (lineseg-copy (car lineseg-list))))
      (for-each
       (lambda (lineseg2)
         (%intersect! lineseg1 lineseg2))
       (cdr lineseg-list))
      lineseg1)))


;; 線分の和集合を取得
(define (lineseg-union :rest lineseg-list)
  (if (null? lineseg-list)
    #f
    (let ((lineseg1 (lineseg-copy (car lineseg-list))))
      ;; 線分の集合を結合してから、正規化する
      (for-each
       (lambda (lineseg2)
         (set! (slot-ref lineseg1 'segs)
               (append (slot-ref lineseg2 'segs) (slot-ref lineseg1 'segs))))
       (cdr lineseg-list))
      (%lineseg-normalize! lineseg1))))


;; 線分の差集合を取得
(define (lineseg-subtract :rest lineseg-list)
  ;; 2個の線分の差集合を取得して、lineseg1 にセットする(内部処理用)
  (define (%subtract! lineseg1 lineseg2)
    (define cmpr      (slot-ref lineseg1 'comparator))
    (define segs2     (slot-ref lineseg2 'segs))
    (define index2    0)
    (define segs1-new
      (fold
       (lambda (seg1 segs1-temp)
         (let loop ()
           (when (< index2 (length segs2))
             (let* ((seg2       (list-ref segs2 index2))
                    (seg1-start (list-ref seg1 0))
                    (seg1-end   (list-ref seg1 1))
                    (seg2-start (list-ref seg2 0))
                    (seg2-end   (list-ref seg2 1)))
               ;; 共通部分を取り除く
               (when (and (<? cmpr seg1-start seg2-end)
                          (<? cmpr seg2-start seg1-end))
                 ;; 残った部分の前半を抽出
                 (when (<? cmpr seg1-start seg2-start)
                   (push! segs1-temp (list seg1-start seg2-start)))
                 ;; 残った部分の後半をセット
                 (if   (<? cmpr seg2-end   seg1-end)
                   (set! seg1 (list seg2-end seg1-end))
                   (set! seg1 #f)))
               ;; まだ共通部分がある可能性があるなら、繰り返す
               (when (>? cmpr seg1-end seg2-end)
                 (inc! index2)
                 (loop))
               )))
         ;; 最後に残った部分があれば抽出
         (when seg1 (push! segs1-temp seg1))
         segs1-temp)
       '()
       (slot-ref lineseg1 'segs)))
    (slot-set! lineseg1 'segs (reverse segs1-new)))

  ;; 線分の差集合を取得
  (if (null? lineseg-list)
    #f
    (let ((lineseg1 (lineseg-copy (car lineseg-list))))
      (for-each
       (lambda (lineseg2)
         (%subtract! lineseg1 lineseg2))
       (cdr lineseg-list))
      lineseg1)))


;; 線分の正規化(内部処理用)
(define (%lineseg-normalize! lineseg1)
  (define cmpr         (slot-ref lineseg1 'comparator))
  (define segs1        (slot-ref lineseg1 'segs))
  (define segs1-sorted (sort segs1 cmpr car)) ; 始点でソートする
  (define segs1-new
    (if (null? segs1-sorted)
      '()
      (fold
       (lambda (seg1 segs1-temp)
         (let* ((last-seg   (car segs1-temp))
                (seg1-start (list-ref seg1     0))
                (seg1-end   (list-ref seg1     1))
                (last-start (list-ref last-seg 0))
                (last-end   (list-ref last-seg 1)))
           ;; 線分に重複があれば、マージする
           (if (and (<=? cmpr seg1-start last-end)
                    (<=? cmpr last-start seg1-end))
             (set-car! segs1-temp
                       (list (if (<=? cmpr seg1-start last-start) seg1-start last-start)
                             (if (>=? cmpr seg1-end   last-end)   seg1-end   last-end)))
             (push! segs1-temp seg1)))
         segs1-temp)
       (take segs1-sorted 1)
       (cdr segs1-sorted))))
  (slot-set! lineseg1 'segs (reverse segs1-new))
  lineseg1)

