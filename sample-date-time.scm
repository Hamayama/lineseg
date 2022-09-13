;;
;; Date time calculation sample
;;

(add-load-path "." :relative)
(use srfi-19)
(use lineseg)

;; ===== 日時関係のツール類 =====

;; 日時の範囲を作成する
(define (make-date-lineseg segs)
  (make-lineseg segs
                :comparator date-comparator
                :add-func   time-add
                :sub-func   date-diff))

;; 日時の比較器
(define date-comparator
  (make-comparator
   date?
   (lambda (date1 date2) (time=? (date->time-utc date1) (date->time-utc date2)))
   (lambda (date1 date2) (time<? (date->time-utc date1) (date->time-utc date2)))
   default-hash))

;; 日時を減算して時間を求める
(define (date-diff :rest dates)
  (if (null? dates)
    #f
    (fold (lambda (date1 result-time)
            (time-difference result-time (date->time-utc date1)))
          (date->time-utc (car dates))
          (cdr dates))))

;; 日時に時間を加算する
;; (加算する時間のタイプは、time-duration である必要がある)
(define (date-add-time date1 time1)
  (time-utc->date (add-duration (date->time-utc date1) time1)
                  (date-zone-offset date1)))

;; 日時から時間を減算する
;; (減算する時間のタイプは、time-duration である必要がある)
(define (date-sub-time date1 time1)
  (time-utc->date (subtract-duration (date->time-utc date1) time1)
                  (date-zone-offset date1)))

;; 時間を加算する
(define (time-add :rest times)
  (if (null? times)
    #f
    (fold (lambda (time1 result-time)
            (add-duration result-time time1))
          (car times)
          (cdr times))))

;; 時間を減算する
(define (time-sub :rest times)
  (if (null? times)
    #f
    (fold (lambda (time1 result-time)
            (subtract-duration result-time time1))
          (car times)
          (cdr times))))


;; ===== 使用例 =====

(define *date-format* "~Y-~m-~dT~H:~M:~S~z")
(define *hour-sec*    3600)
(define (time-to-hour time) (/. (time-second time) *hour-sec*))

;; 定時
(define day-start   (string->date "2000-01-01T08:30:00+0900" *date-format*))
(define day-end     (string->date "2000-01-01T17:00:00+0900" *date-format*))
;; 昼休み
(define lunch-start (string->date "2000-01-01T12:15:00+0900" *date-format*))
(define lunch-end   (string->date "2000-01-01T13:00:00+0900" *date-format*))
;; 休憩
(define rest-start  (string->date "2000-01-01T17:00:00+0900" *date-format*))
(define rest-end    (string->date "2000-01-01T17:15:00+0900" *date-format*))
;; 実時間
(define work-start  (string->date "2000-01-01T08:00:00+0900" *date-format*))
(define work-end    (string->date "2000-01-01T18:30:00+0900" *date-format*))

;; 各時間の範囲を作成
(define day-seg     (make-date-lineseg `((,day-start   ,day-end))))
(define lunch-seg   (make-date-lineseg `((,lunch-start ,lunch-end))))
(define rest-seg    (make-date-lineseg `((,rest-start  ,rest-end))))
(define work-seg    (make-date-lineseg `((,work-start  ,work-end))))

;; 各時間の長さを表示
(print "day-time   = " (time-to-hour (lineseg-length day-seg))   " hr")
(print "lunch-time = " (time-to-hour (lineseg-length lunch-seg)) " hr")
(print "rest-time  = " (time-to-hour (lineseg-length rest-seg))  " hr")
(print)

;; 実時間、定時内時間、定時外時間の長さを計算
(define all-work-time     (lineseg-length (lineseg-subtract work-seg lunch-seg rest-seg)))
(define regular-work-time (lineseg-length (lineseg-subtract (lineseg-intersect work-seg day-seg)
                                                            lunch-seg
                                                            rest-seg)))
(define extra-work-time   (time-sub all-work-time regular-work-time))

;; 実時間、定時内時間、定時外時間の長さを表示
(print "all-work-time     = " (time-to-hour all-work-time)     " hr")
(print "regular-work-time = " (time-to-hour regular-work-time) " hr")
(print "extra-work-time   = " (time-to-hour extra-work-time)   " hr")

