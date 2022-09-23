;; -*- coding: utf-8 -*-
;;
;; datecal.scm
;; 2022-9-23 v1.01
;;
;; ＜内容＞
;;   Gauche で、日時の計算を行うためのモジュールです。
;;
;;   詳細については、以下のページを参照ください。
;;   https://github.com/Hamayama/datecal
;;
(define-module datecal
  (use srfi-19)
  (export
    date-calc-comparator
    time-calc-comparator
    date-copy
    time-copy
    date-diff
    date-add-time
    date-sub-time
    time-add
    time-sub
    ))
(select-module datecal)

;; ジェネリック関数のメソッドを種別を指定して取得する(内部処理用)
;; 引数
;;   gf            ジェネリック関数(例えば object-apply 等)
;;   required      メソッドの引数の数(省略可能引数は除く)
;;   optional      メソッドの省略可能引数の有無(#tまたは#f)
;;   specializers  メソッドの引数の型を示す特定化子リスト(例えば `(,<number> ,<string>) 等)
(define (%get-gf-method gf required optional specializers)
  (find
   (lambda (m)
     (and (equal? required     (slot-ref m 'required))
          (equal? optional     (slot-ref m 'optional))
          (equal? specializers (slot-ref m 'specializers))))
   (slot-ref gf 'methods)))


;; 日時の object-hash が存在しなければ追加する
;;
;; (Gauche 0.9.12 の時点では存在しない)
;;
(unless (%get-gf-method object-hash 2 #f `(,<date> ,<top>))
  (define-method object-hash ((obj <date>) rec-hash)
    (fold
     (lambda (val seed)
       (combine-hash-value seed (rec-hash (slot-ref obj val))))
     (rec-hash (slot-ref obj 'year))
     '(month day hour minute second nanosecond zone-offset))))


;; 日時計算用の比較器
;;
;; (日時の object-equal? と object-compare は、srfi-19.scm で定義されている。
;;  このため、equal? と compare が使用できる。
;;  default-hash は使えなかった (異なる日時でも同じ値が返る) ため、
;;  上で object-hash を定義した)
;;
(define date-calc-comparator
  (make-comparator
   date?
   equal?
   (lambda (date1 date2) (< (compare date1 date2) 0))
   default-hash))


;; 時間計算用の比較器
;;
;; (時間の time_compare と time_hash は、system.c で実装されている。
;;  このため、equal? と compare と default-hash が使用できる)
;;
(define time-calc-comparator
  (make-comparator
   time?
   equal?
   (lambda (time1 time2) (< (compare time1 time2) 0))
   default-hash))


;; 日時のコピー
(define (date-copy date1)
  (make-date
   (date-nanosecond  date1)
   (date-second      date1)
   (date-minute      date1)
   (date-hour        date1)
   (date-day         date1)
   (date-month       date1)
   (date-year        date1)
   (date-zone-offset date1)))

;; 時間のコピー
(define (time-copy time1)
  (make-time
   (time-type       time1)
   (time-nanosecond time1)
   (time-second     time1)))

;; 日時を減算して時間を求める
(define (date-diff :rest dates)
  (if (null? dates)
    #f
    (fold
     (lambda (date1 result-time)
       (time-difference result-time (date->time-monotonic date1)))
     (date->time-monotonic (car dates))
     (cdr dates))))

;; 日時に時間を加算する
;; (加算する時間のタイプは、time-duration である必要がある)
(define (date-add-time date1 :rest times)
  (time-monotonic->date
   (fold
    (lambda (time1 result-time)
      (add-duration result-time time1))
    (date->time-monotonic date1)
    times)
   (date-zone-offset date1)))

;; 日時から時間を減算する
;; (減算する時間のタイプは、time-duration である必要がある)
(define (date-sub-time date1 :rest times)
  (time-monotonic->date
   (fold
    (lambda (time1 result-time)
      (subtract-duration result-time time1))
    (date->time-monotonic date1)
    times)
   (date-zone-offset date1)))

;; 時間を加算する
(define (time-add :rest times)
  (if (null? times)
    #f
    (fold
     (lambda (time1 result-time)
       (add-duration result-time time1))
     (car times)
     (cdr times))))

;; 時間を減算する
(define (time-sub :rest times)
  (if (null? times)
    #f
    (fold
     (lambda (time1 result-time)
       (subtract-duration result-time time1))
     (car times)
     (cdr times))))

