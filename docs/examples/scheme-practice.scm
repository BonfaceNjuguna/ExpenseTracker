;; Standalone Scheme practice. From the repository root:
;;   gsi docs/examples/scheme-practice.scm
;; No LambdaNative, GUI, network or application database is loaded.

(define (check-equal label actual expected)
  (if (not (equal? actual expected))
      (error label actual expected)
      (begin (display "PASS: ") (display label) (newline))))

(define (balance income expenses) (- income expenses))
(check-equal "prefix arithmetic" (- 1000 (+ 150 50)) 800)
(check-equal "named procedure" (balance 100000 1250) 98750)
(check-equal "only #f is false" (if '() "yes" "no") "yes")
(check-equal "invalid number text" (string->number "oops") #f)

(define row '("17" "Expense" "1250" "Bus fare" "Transport" "2026-10-29 15:10:00"))
(check-equal "row category" (list-ref row 4) "Transport")
(check-equal "parse stored cents" (string->number (caddr row)) 1250)
(check-equal "map transforms a list" (map (lambda (n) (* n 2)) '(1 2 3)) '(2 4 6))
(check-equal "apply spreads arguments" (apply + '(100 20 5)) 125)
(check-equal "member returns a suffix" (member "Other" '("Salary" "Other")) '("Other"))

(define (make-adder n) (lambda (x) (+ x n)))
(check-equal "closure remembers n" ((make-adder 10) 5) 15)

(define title "Personal Finance")
(check-equal "quasiquoted form data" `(label text ,title) '(label text "Personal Finance"))

(define (sum-cents xs)
  (let loop ((remaining xs) (total 0))
    (if (null? remaining) total
        (loop (cdr remaining) (+ total (car remaining))))))
(check-equal "tail-recursive total" (sum-cents '(10 20 1250)) 1280)

(display "All Scheme practice examples passed.")
(newline)
