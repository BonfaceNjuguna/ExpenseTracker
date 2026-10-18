(define db #f)
(define gui #f)
(define form #f)

;; sqlite-query returns #f on a SQL error and an empty list for successful writes.
(define (expense-query sql)
  (or (sqlite-query db sql) (error "Expense database query failed" sql)))

(define (expense-total type)
  (caar (expense-query
    (string-append "SELECT COALESCE(SUM(amount), 0) FROM transactions WHERE type='"
                   type "'"))))

;; SQLite string literals escape apostrophes by doubling them.
(define (expense-sql-string value)
  (list->string
    (apply append
      (map (lambda (ch) (if (char=? ch #\') (list ch ch) (list ch)))
           (string->list value)))))

;; uiform supports a flat sequence of widgets, using size for font selection.
(define expense-tracker-form
  (list->table
    `((main
        "Expense Tracker"
        #f
        #f
        (label text "Welcome" align left size big)
        (label text "Total Balance" align left)
        (label text ,(lambda ()
                      (string-append
                        (number->string (- (expense-total "Income")
                                           (expense-total "Expense"))) " KES"))
               align left size header)
        (label text ,(lambda ()
                      (string-append "Income: " (number->string (expense-total "Income")) " KES"))
               align left)
        (label text ,(lambda ()
                      (string-append "Expenses: " (number->string (expense-total "Expense")) " KES"))
               align left)
        (spacer height 10)
        (button text "Add Transaction" size big action addtransaction)
        (spacer height 10)
        (label text "Transaction History" align left)
        (list id transactionhistory location ui align left
              entries ,(lambda ()
                         (map (lambda (row)
                                (string-append (car row) ": "
                                               (number->string (cadr row)) " KES - "
                                               (or (caddr row) "")))
                              (expense-query
                                "SELECT type, amount, description FROM transactions ORDER BY rowid DESC"))))
        (button text "Logout" action ,(lambda () (terminate))))
      (addtransaction
        "Add Transaction"
        ("Back" main)
        #f
        (spacer height 10)
        (dropdown id type label "Type:" entries ("Income" "Expense") location ui)
        (textentry id amount text "Amount:" keypad numint location ui default "0")
        (textentry id description text "Description:" location ui default "")
        (button text "Save"
          action ,(lambda ()
                    (let* ((type (uiget 'type "Income"))
                           (amount (string->number (uiget 'amount "0")))
                           (description (uiget 'description "")))
                      (if (and amount (real? amount) (> amount 0)
                               (member type '("Income" "Expense")))
                          (begin
                            (expense-query
                              (string-append
                                "INSERT INTO transactions (type, amount, description) VALUES ('"
                                type "'," (number->string amount) ",'"
                                (expense-sql-string description) "')"))
                            'main)
                          '("Enter an amount greater than zero." ("OK" #f))))))))))

(main
  (lambda (w h)
    ;; LambdaNative only writes exception backtraces when its log folder exists.
    (if (not (file-exists? log:path)) (create-directory log:path))
    (log-reset!)
    (log-system "ExpenseTracker: initializing")

    (make-window 480 800)
    (glgui-orientation-set! GUI_PORTRAIT)
    (set! db (sqlite-open (string-append (system-directory) "/expense.sqlite")))
    (if (not db) (error "Cannot open expense database"))
    (expense-query
      "CREATE TABLE IF NOT EXISTS transactions (type TEXT, amount INTEGER, description TEXT)")

    (set! gui (make-glgui))
    (let ((aw (glgui-width-get))
          (ah (glgui-height-get)))
      (glgui-box gui 0 0 aw ah DarkGreen)
      (set! form (glgui-uiform gui 0 0 aw ah)))
    (glgui-widget-set! gui form 'sandbox (system-directory))
    (glgui-widget-set! gui form 'database (make-table))
    (glgui-widget-set! gui form 'fnt ascii_18.fnt)
    (glgui-widget-set! gui form 'smlfnt ascii_14.fnt)
    (glgui-widget-set! gui form 'hdfnt ascii_24.fnt)
    (glgui-widget-set! gui form 'bigfnt ascii_40.fnt)
    (glgui-widget-set! gui form 'uiform expense-tracker-form)
    (glgui-widget-set! gui form 'type "Income")
    (log-system "ExpenseTracker: initialized"))
  (lambda (t x y)
    (if (and (= t EVENT_KEYPRESS) (= x EVENT_KEYESCAPE)) (terminate))
    (glgui-event gui t x y))
  (lambda ()
    (when db (sqlite-close db) (set! db #f))
    #t)
  (lambda () (glgui-suspend))
  (lambda () (glgui-resume)))
