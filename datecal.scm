;; -*- coding: utf-8 -*-
;;
;; datecal.scm
;; 2022-9-19 v1.00
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
    date-diff
    date-add-time
    date-sub-time
    time-add
    time-sub
    ))
(select-module datecal)

;; 日時のハッシュ値計算(内部処理用)
(define (%date-hash date1)
  (fold
   (lambda (val seed)
     (combine-hash-value val seed))
   (default-hash (slot-ref date1 'year))
   `(,(default-hash (slot-ref date1 'month))
     ,(default-hash (slot-ref date1 'day))
     ,(default-hash (slot-ref date1 'hour))
     ,(default-hash (slot-ref date1 'minute))
     ,(default-hash (slot-ref date1 'second))
     ,(default-hash (slot-ref date1 'nanosecond))
     ,(default-hash (slot-ref date1 'zone-offset)))))

;; 時間のハッシュ値計算(内部処理用)
(define (%time-hash time1)
  (fold
   (lambda (val seed)
     (combine-hash-value val seed))
   (default-hash (slot-ref time1 'type))
   `(,(default-hash (slot-ref time1 'second))
     ,(default-hash (slot-ref time1 'nanosecond)))))

;; 日時計算用の比較器
(define date-calc-comparator
  (make-comparator
   date?
   (lambda (date1 date2) (time=? (date->time-utc date1) (date->time-utc date2)))
   (lambda (date1 date2) (time<? (date->time-utc date1) (date->time-utc date2)))
   %date-hash))

;; 時間計算用の比較器
(define time-calc-comparator
  (make-comparator
   time?
   time=?
   time<?
   %time-hash))

;; 日時を減算して時間を求める
(define (date-diff :rest dates)
  (if (null? dates)
    #f
    (fold
     (lambda (date1 result-time)
       (time-difference result-time (date->time-utc date1)))
     (date->time-utc (car dates))
     (cdr dates))))

;; 日時に時間を加算する
;; (加算する時間のタイプは、time-duration である必要がある)
(define (date-add-time date1 :rest times)
  (fold
   (lambda (time1 result-date)
     (time-utc->date (add-duration (date->time-utc result-date) time1)
                     (date-zone-offset result-date)))
   date1
   times))

;; 日時から時間を減算する
;; (減算する時間のタイプは、time-duration である必要がある)
(define (date-sub-time date1 :rest times)
  (fold
   (lambda (time1 result-date)
     (time-utc->date (subtract-duration (date->time-utc result-date) time1)
                     (date-zone-offset result-date)))
   date1
   times))

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

