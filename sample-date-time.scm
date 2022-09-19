;;
;; Date time calculation sample
;;

(add-load-path "." :relative)
(use srfi-19)
(use datecal)
(use lineseg)

;; 日時の範囲を設定して、勤務時間を計算するサンプル

(define (make-date-lineseg segs)
  (make-lineseg segs
                :comparator date-calc-comparator
                :add-func   time-add
                :sub-func   date-diff))

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
;; 出勤時間
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

;; 実勤務時間、定時内勤務時間、時間外勤務時間の長さを計算
(define all-work-time     (lineseg-length (lineseg-subtract work-seg lunch-seg rest-seg)))
(define regular-work-time (lineseg-length (lineseg-subtract (lineseg-intersect work-seg day-seg)
                                                            lunch-seg
                                                            rest-seg)))
(define extra-work-time   (time-sub all-work-time regular-work-time))

;; 実勤務時間、定時内勤務時間、時間外勤務時間の長さを表示
(print "all-work-time     = " (time-to-hour all-work-time)     " hr")
(print "regular-work-time = " (time-to-hour regular-work-time) " hr")
(print "extra-work-time   = " (time-to-hour extra-work-time)   " hr")

