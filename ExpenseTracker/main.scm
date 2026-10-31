;; Workshop iteration: local finances, with no account or network dependency.
(define db #f)
(define gui #f)
(define entry-gui #f)
(define form #f)
(define expense-edit-id #f)
(define expense-view 'overview)
(define expense-filter "All")
(define expense-return-view 'overview)
(define expense-picker-gui #f)
(define expense-list #f)
(define expense-list-gui #f)
(define expense-income-categories '("Salary" "Business" "Freelance" "Investments" "Gifts" "Other"))
(define expense-spending-categories '("Food & drink" "Transport" "Bills" "Shopping" "Health" "Education" "Entertainment" "Other"))

(define (expense-category-options type)
  (if (string=? type "Income") expense-income-categories expense-spending-categories))

(define (expense-current-category)
  (let* ((type (uiget 'type "Expense"))
         (previous-type (uiget 'category-type type))
         (options (expense-category-options type))
         (selected (uiget 'category "Other")))
    (if (or (not (string=? type previous-type)) (not (member selected options)))
        (begin
          (glgui-widget-set! entry-gui form 'category "Other")
          (glgui-widget-set! entry-gui form 'custom-category "")
          (glgui-widget-set! entry-gui form 'category-type type)
          "Other")
        selected)))

(define expense-bg (color-rgb 12 19 30))
(define expense-panel (color-rgb 24 35 50))
(define expense-muted (color-rgb 153 170 189))
(define expense-ink (color-rgb 235 242 248))
(define expense-mint (color-rgb 181 241 208))
(define expense-coral (color-rgb 255 186 160))

(define (expense-query sql)
  (or (sqlite-query db sql) (error "Expense database query failed" sql)))

(define (expense-sql-string value)
  (list->string (apply append
    (map (lambda (ch) (if (char=? ch #\') (list ch ch) (list ch)))
         (string->list value)))))

(define (expense-trim value)
  (let ((n (string-length value)))
    (let start ((a 0))
      (if (and (< a n) (char-whitespace? (string-ref value a))) (start (+ a 1))
        (let end ((b n))
          (if (and (> b a) (char-whitespace? (string-ref value (- b 1)))) (end (- b 1))
            (substring value a b)))))))

;; Parse decimal text directly to integer cents: reject exponents, signs,
;; fractions and non-finite values rather than rounding an arbitrary number.
(define (expense-parse-cents text)
  (let* ((s (expense-trim text)) (n (string-length s)))
    (let loop ((i 0) (whole 0) (fraction 0) (digits 0) (decimal? #f) (whole-digits 0))
      (if (= i n)
          (and (> whole-digits 0) (or (not decimal?) (> digits 0))
               (let ((cents (+ (* whole 100) (* fraction (if (= digits 1) 10 1)))))
                 (and (<= cents 99999999999) cents)))
          (let ((ch (string-ref s i)))
            (cond
              ((and (char>=? ch #\0) (char<=? ch #\9))
               (let ((d (- (char->integer ch) (char->integer #\0))))
                 (if decimal?
                     (and (< digits 2) (loop (+ i 1) whole (+ (* fraction 10) d) (+ digits 1) #t whole-digits))
                     (and (< whole-digits 9) (loop (+ i 1) (+ (* whole 10) d) fraction digits #f (+ whole-digits 1))))))
              ((and (char=? ch #\.) (not decimal?))
               (loop (+ i 1) whole fraction digits #t whole-digits))
              (else #f)))))))

(define (expense-decimal cents)
  (let ((fraction (modulo (abs cents) 100)))
    (string-append (if (< cents 0) "-" "")
      (number->string (quotient (abs cents) 100)) "."
      (if (< fraction 10) "0" "") (number->string fraction))))

(define (expense-group-digits text)
  (let ((n (string-length text)))
    (let loop ((i 0) (result ""))
      (if (= i n) result
          (loop (+ i 1) (string-append result
            (if (and (> i 0) (= (modulo (- n i) 3) 0)) "," "")
            (substring text i (+ i 1))))))))

(define (expense-money cents)
  (let ((s (expense-decimal (abs cents))))
    (string-append (if (< cents 0) "-" "") "KES "
      (expense-group-digits (substring s 0 (- (string-length s) 3)))
      (substring s (- (string-length s) 3) (string-length s)))))

(define (expense-initialize-db!)
  (expense-query "CREATE TABLE IF NOT EXISTS transactions (type TEXT, amount NUMERIC, description TEXT)")
  ;; Upgrade the original table in place, preserving its rows and amount column.
  (expense-query "BEGIN IMMEDIATE")
  (with-exception-catcher
    (lambda (e) (sqlite-query db "ROLLBACK") (raise e))
    (lambda ()
      (let ((columns (map cadr (expense-query "PRAGMA table_info(transactions)"))))
        (for-each (lambda (column)
                    (if (not (member (car column) columns))
                        (expense-query (string-append "ALTER TABLE transactions ADD COLUMN " (cadr column)))))
          '(("category" "category TEXT NOT NULL DEFAULT 'General'")
            ("created_at" "created_at TEXT NOT NULL DEFAULT ''")
            ("amount_cents" "amount_cents INTEGER"))))
      (expense-query "UPDATE transactions SET amount_cents=CAST(ROUND(amount * 100) AS INTEGER) WHERE amount_cents IS NULL")
      (expense-query "COMMIT"))))

;; The pinned SQLite wrapper reads integer columns as 32-bit C ints. Return
;; monetary values as TEXT, then parse in Scheme to preserve larger totals.
(define (expense-total type)
  (string->number (caar (expense-query
    (string-append "SELECT CAST(COALESCE(SUM(amount_cents),0) AS TEXT) FROM transactions WHERE type='" type "'")))))

(define (expense-rows filter . limit)
  (expense-query (string-append
    "SELECT CAST(rowid AS TEXT), type, CAST(amount_cents AS TEXT), description, category, created_at FROM transactions"
    (if (member filter '("Income" "Expense")) (string-append " WHERE type='" filter "'") "")
    " ORDER BY rowid DESC" (if (null? limit) "" (string-append " LIMIT " (number->string (car limit)))))))

(define (expense-valid-id? id)
  (and (integer? id) (exact? id) (> id 0)))

(define (expense-find-row id)
  (and (expense-valid-id? id)
       (let ((rows (expense-query (string-append
         "SELECT CAST(rowid AS TEXT), type, CAST(amount_cents AS TEXT), description, category, created_at FROM transactions WHERE rowid="
         (number->string id)))))
         (and (pair? rows) (car rows)))))

(define (expense-record! type amount category description . custom-name)
  (expense-write! #f type amount category description (if (pair? custom-name) (car custom-name) "")))

(define (expense-update! id type amount category description . custom-name)
  (if (expense-find-row id)
      (expense-write! id type amount category description (if (pair? custom-name) (car custom-name) ""))
      "This transaction no longer exists."))

(define (expense-delete! id)
  (if (expense-find-row id)
      (begin
        (expense-query (string-append "DELETE FROM transactions WHERE rowid=" (number->string id)))
        #t)
      "This transaction no longer exists."))

(define (expense-write! id type amount category description custom-name)
  (let* ((cents (expense-parse-cents amount))
         (custom (expense-trim custom-name))
         (stored-category (if (and (string=? category "Other") (> (string-length custom) 0)) custom category)))
    (cond
      ((not (member type '("Income" "Expense"))) "Choose income or expense.")
      ((or (not cents) (<= cents 0)) "Enter a positive amount with up to two decimal places.")
      ((not (member category (expense-category-options type))) "Choose a category for this transaction type.")
      ((and (string=? category "Other") (> (string-length custom) 40)) "Keep the category name to 40 characters or fewer.")
      ((> (string-length description) 200) "Keep the description to 200 characters or fewer.")
      (else
        (expense-query
          (if id
              (string-append "UPDATE transactions SET type='" type "',amount=" (expense-decimal cents)
                ",description='" (expense-sql-string (expense-trim description)) "',category='"
                (expense-sql-string stored-category) "',amount_cents=" (number->string cents)
                " WHERE rowid=" (number->string id))
              (string-append
                "INSERT INTO transactions (type, amount, description, category, created_at, amount_cents) VALUES ('"
                type "'," (expense-decimal cents) ",'" (expense-sql-string (expense-trim description))
                "','" (expense-sql-string stored-category) "',datetime('now','localtime')," (number->string cents) ")")))
        #t))))

;; Custom glGUI dashboard: explicit spacing, cards and a scrollable ledger.
(define (expense-label g x y w h text font color . align)
  (let ((widget (glgui-label g x y w h text font color)))
    (if (pair? align) (glgui-widget-set! g widget 'align (car align)))
    widget))

(define (expense-card g x y w h color)
  (let ((widget (glgui-box g x y w h color)))
    (glgui-widget-set! g widget 'rounded #t)
    widget))

(define (expense-button g x y w h title color text-color callback)
  (let ((widget (glgui-button-string g x y w h title heading_14.fnt callback)))
    (glgui-widget-set! g widget 'solid-color #t)
    (glgui-widget-set! g widget 'button-normal-color color)
    (glgui-widget-set! g widget 'button-selected-color (color-shade color 0.8))
    (glgui-widget-set! g widget 'color text-color)
    widget))

(define (expense-row-draw row)
  (lambda (g widget x y w h selected?)
    (let* ((income? (string=? (cadr row) "Income"))
           (color (if income? expense-mint expense-coral))
           (description (list-ref row 3))
           (category (list-ref row 4))
           (date (list-ref row 5))
           (title (if (or (not description) (string=? description "")) category description))
           (amount (string-append (if income? "+" "-") (expense-money (string->number (caddr row))))))
      (glgui:draw-rounded-box (+ x 2) (+ y 9) 34 34 expense-panel)
      (glgui:draw-text-center (+ x 2) (+ y 9) 34 34 (if income? "+" "-") heading_18.fnt color)
      (glgui:draw-text-left (+ x 48) (+ y 28) (- (* w 0.52) 54) 22 title heading_14.fnt expense-ink)
      (glgui:draw-text-left (+ x 48) (+ y 7) (- w 54) 18
        (string-append category "  /  " (if (and date (>= (string-length date) 10)) (substring date 0 10) "Earlier entry"))
        body_12.fnt expense-muted)
      (glgui:draw-text-right (+ x (* w 0.52)) (+ y 28) (- (* w 0.48) 6) 22 amount (if (> (string-length amount) 20) body_12.fnt heading_14.fnt) color)
      (glgui:draw-box x y w 1 expense-panel))))

(define (expense-draw-ledger g rows y height)
  (set! expense-list #f)
  (if (null? rows)
      (begin
        (expense-card g 24 y (- (glgui-width-get) 48) height expense-panel)
        (expense-label g 42 (+ y (/ height 2)) (- (glgui-width-get) 84) 28
          (if (string=? expense-filter "All") "A fresh start for your finances" "No matching transactions yet") heading_16.fnt expense-ink)
        (expense-label g 42 (+ y (/ height 2) -29) (- (glgui-width-get) 84) 24
          "Add your first income or expense above." body_12.fnt expense-muted))
      (let ((widget (glgui-list g 24 y (- (glgui-width-get) 48) height 64 (map expense-row-draw rows)
                      (lambda (g widget . args)
                        (let ((index (glgui-widget-get g widget 'current)))
                          (if (and (>= index 0) (< index (length rows)))
                              (expense-open-transaction! (string->number (car (list-ref rows index))))))))))
        (set! expense-list widget)
        (set! expense-list-gui g)
        (glgui-widget-set! g widget 'bgcol1 expense-bg)
        (glgui-widget-set! g widget 'bgcol2 expense-bg)
        (glgui-widget-set! g widget 'autohidebar #t)
        (glgui-widget-set! g widget 'scrollcolor expense-muted))))

(define (expense-nav! g w)
  (expense-card g 24 20 (- w 48) 52 expense-panel)
  (expense-button g 30 26 (/ (- w 72) 2) 40 "Overview"
    (if (eq? expense-view 'overview) expense-mint expense-panel)
    (if (eq? expense-view 'overview) expense-bg expense-muted)
    (lambda args (expense-show-view! 'overview)))
  (expense-button g (+ 42 (/ (- w 72) 2)) 26 (/ (- w 72) 2) 40 "Activity"
    (if (eq? expense-view 'activity) expense-mint expense-panel)
    (if (eq? expense-view 'activity) expense-bg expense-muted)
    (lambda args (expense-show-view! 'activity))))

(define (expense-show-view! view)
  (set! expense-edit-id #f)
  (set! expense-view view)
  (set! gui (make-glgui))
  (let* ((w (glgui-width-get)) (h (glgui-height-get)) (cw (- w 48))
         (income (expense-total "Income")) (expense (expense-total "Expense"))
         (rows (if (eq? view 'activity) (expense-rows expense-filter) (expense-rows "All" 10))))
    (glgui-box gui 0 0 w h expense-bg)
    (expense-label gui 24 (- h 48) 230 24 "PERSONAL FINANCE" heading_12.fnt expense-mint)
    (expense-label gui (- w 166) (- h 48) 142 24 "ON THIS DEVICE" body_12.fnt expense-muted GUI_ALIGNRIGHT)
    (expense-label gui 24 (- h 101) cw 43
      (if (eq? view 'overview) "Your money, clearly." "Your activity") heading_28.fnt expense-ink)
    (expense-label gui 24 (- h 127) cw 23
      (if (eq? view 'overview) "Small steps. A clearer financial picture." "Every income and expense, in one place.") body_14.fnt expense-muted)
    (if (eq? view 'overview)
        (begin
          (expense-card gui 24 (- h 297) cw 148 expense-mint)
          (expense-label gui 46 (- h 187) (- cw 44) 22 "AVAILABLE BALANCE" heading_12.fnt expense-bg)
          (let ((balance (expense-money (- income expense))))
            (expense-label gui 46 (- h 245) (- cw 44) 50 balance
              (if (> (string-length balance) 19) heading_22.fnt heading_36.fnt) expense-bg))
          (expense-label gui 46 (- h 278) (- cw 44) 22 "All-time income minus expenses" body_12.fnt expense-bg)
          (let ((cardw (/ (- cw 12) 2)))
            (expense-card gui 24 (- h 403) cardw 90 expense-panel)
            (expense-card gui (+ 36 cardw) (- h 403) cardw 90 expense-panel)
            (expense-label gui 40 (- h 344) (- cardw 28) 22 "INCOME" heading_12.fnt expense-mint)
            (expense-label gui 40 (- h 385) (- cardw 28) 32 (expense-money income) (if (> (string-length (expense-money income)) 16) heading_14.fnt heading_18.fnt) expense-ink)
            (expense-label gui (+ 52 cardw) (- h 344) (- cardw 28) 22 "EXPENSES" heading_12.fnt expense-coral)
            (expense-label gui (+ 52 cardw) (- h 385) (- cardw 28) 32 (expense-money expense) (if (> (string-length (expense-money expense)) 16) heading_14.fnt heading_18.fnt) expense-ink))
          (expense-button gui 24 (- h 467) (/ (- cw 12) 2) 48 "+ Income" expense-mint expense-bg
            (lambda args (expense-open-entry! "Income")))
          (expense-button gui (+ 36 (/ (- cw 12) 2)) (- h 467) (/ (- cw 12) 2) 48 "- Expense" expense-panel expense-coral
            (lambda args (expense-open-entry! "Expense")))
          (expense-label gui 24 (- h 514) cw 28 "Latest 10 transactions" heading_18.fnt expense-ink)
          (expense-draw-ledger gui rows 96 (max 64 (- h 628))))
        (begin
          (expense-button gui 24 (- h 199) (/ (- cw 12) 2) 48 "+ Income" expense-mint expense-bg
            (lambda args (expense-open-entry! "Income")))
          (expense-button gui (+ 36 (/ (- cw 12) 2)) (- h 199) (/ (- cw 12) 2) 48 "- Expense" expense-panel expense-coral
            (lambda args (expense-open-entry! "Expense")))
          (let ((fw (/ (- cw 16) 3)))
            (for-each (lambda (filter i)
                        (expense-button gui (+ 24 (* i (+ fw 8))) (- h 257) fw 38
                          (if (string=? filter "Expense") "Expenses" filter)
                          (if (string=? expense-filter filter) expense-mint expense-panel)
                          (if (string=? expense-filter filter) expense-bg expense-muted)
                          (lambda args (set! expense-filter filter) (expense-show-view! 'activity))))
              '("All" "Income" "Expense") '(0 1 2)))
          (expense-label gui 24 (- h 303) cw 26
            (string-append (number->string (length rows)) (if (= (length rows) 1) " transaction" " transactions")) heading_16.fnt expense-ink)
          (expense-draw-ledger gui rows 96 (max 64 (- h 420)))))
    (expense-nav! gui w)))

(define (expense-save-form!)
  (let ((result (with-exception-catcher
                  (lambda (e) (log-error (exception->string e)) "Could not save. Please try again.")
                  (lambda ()
                    (let* ((category (expense-current-category))
                           (custom (uiget 'custom-category "")))
                      (if expense-edit-id
                          (expense-update! expense-edit-id (uiget 'type "Expense") (uiget 'amount "")
                            category (uiget 'description "") custom)
                          (expense-record! (uiget 'type "Expense") (uiget 'amount "")
                            category (uiget 'description "") custom)))))))
    (if (eq? result #t)
        (begin (expense-show-view! expense-return-view) #f)
        (list result '("OK" #f)))))

(define (expense-delete-form!)
  (let ((result (with-exception-catcher
                  (lambda (e) (log-error (exception->string e)) "Could not delete. Please try again.")
                  (lambda () (expense-delete! expense-edit-id)))))
    (if (eq? result #t)
        (begin (expense-show-view! expense-return-view) #f)
        (list result '("OK" #f)))))

(define expense-entry-form
  (list->table
    `((main ,(lambda () (if expense-edit-id "Edit transaction" "New transaction")) ("Cancel" ,(lambda () (expense-show-view! expense-return-view) #f)) #f
       (spacer height 12)
       (label text "Make every transaction count." align left size small color ,expense-muted)
       (spacer height 8)
       (dropdown id type label "Type" entries ("Income" "Expense") location ui)
       (spacer height 12)
       (label text "Amount in KES" align left size small color ,expense-mint)
       (textentry id amount text "" keypad numfloat location ui default "0.00" indent 0.1 indentright 0.1)
       (spacer height 12)
       (label text "Category" align left size small color ,expense-muted)
       (button text ,(lambda () (string-append (expense-current-category) "   >"))
         rounded #t h 52 action ,(lambda () (expense-open-categories!) #f))
       ,(lambda ()
          (if (string=? (expense-current-category) "Other")
              `(label text "Name your category (optional)" align left size small color ,expense-muted)
              '(spacer height 0)))
       ,(lambda ()
          (if (string=? (expense-current-category) "Other")
              '(textentry id custom-category text "" location ui default "" indent 0.1 indentright 0.1)
              '(spacer height 0)))
       (spacer height 12)
       (label text "Description (optional)" align left size small color ,expense-muted)
       (textentry id description text "" location ui default "What was it for?" indent 0.1 indentright 0.1)
       (spacer height 24)
       (button text ,(lambda () (if expense-edit-id "Save changes" "Save transaction")) rounded #t h 52 color ,expense-bg button-color ,expense-mint action ,expense-save-form!)
       ,(lambda ()
          (if expense-edit-id
              `(button text "Delete transaction" rounded #t h 52 color ,expense-bg button-color ,expense-coral action delete)
              '(spacer height 0)))
       (spacer height 12)
       (label text "Saved locally on this device." size small color ,expense-muted))
      (delete "Delete transaction?" ("Back" main) #f
       (spacer height 24)
       (label text "Delete this saved transaction?" align left size big)
       (label text "This cannot be undone. Your balance will update." align left)
       (spacer height 24)
       (button text "Keep transaction" rounded #t h 52 action main)
       (spacer height 12)
       (button text "Delete permanently" rounded #t h 52 color ,expense-bg button-color ,expense-coral action ,expense-delete-form!)))))

(define (expense-open-transaction! id)
  (let ((row (expense-find-row id)))
    (if row (expense-open-entry! (cadr row) row))))

(define (expense-open-entry! type . existing)
  (set! expense-edit-id (and (pair? existing) (string->number (caar existing))))
  (set! expense-return-view expense-view)
  (set! entry-gui (make-glgui))
  (let ((w (glgui-width-get)) (h (glgui-height-get)))
    (glgui-box entry-gui 0 0 w h expense-bg)
    (set! form (glgui-uiform entry-gui 0 0 w h)))
  (for-each (lambda (pair) (glgui-widget-set! entry-gui form (car pair) (cadr pair)))
    (list (list 'sandbox (system-directory)) (list 'uiform expense-entry-form)
      (list 'database (make-table)) (list 'fnt body_16.fnt) (list 'smlfnt body_12.fnt)
      (list 'hdfnt heading_22.fnt) (list 'bigfnt heading_28.fnt) (list 'btfnt heading_14.fnt)
      (list 'headerh 88.0) (list 'rowh 56) (list 'disptime #f)
      (list 'color-header expense-bg) (list 'color-default expense-panel)
      (list 'color-select (color-rgb 47 69 87)) (list 'color-low expense-bg)
      (list 'modal-boxcol expense-panel) (list 'modal-fntcol expense-ink)
      (list 'type type) (list 'category-type type) (list 'category "Other") (list 'custom-category "") (list 'amount "") (list 'description "")))
  (if (pair? existing)
      (let* ((row (car existing)) (category (list-ref row 4))
             (predefined? (member category (expense-category-options type))))
        (glgui-widget-set! entry-gui form 'category (if predefined? category "Other"))
        (glgui-widget-set! entry-gui form 'custom-category (if predefined? "" category))
        (glgui-widget-set! entry-gui form 'amount (expense-decimal (string->number (caddr row))))
        (glgui-widget-set! entry-gui form 'description (or (list-ref row 3) ""))))
  (set! expense-view 'entry))

(define (expense-select-category! category)
  (if (member category (expense-category-options (uiget 'type "Expense")))
      (begin
        (glgui-widget-set! entry-gui form 'category category)
        ;; Other adds a text field, so rebuild uiform's click/scroll map.
        (glgui-widget-set! entry-gui form 'nodemap '())
        (set! expense-view 'entry))))

(define (expense-scroll-list! delta)
  (if expense-list
      (let* ((g expense-list-gui) (widget expense-list)
             (rows (glgui-widget-get g widget 'list))
             (visible (inexact->exact (floor (/ (glgui-widget-get g widget 'h) (glgui-widget-get g widget 'dh)))))
             (maximum (max 0 (- (length rows) visible)))
             (offset (glgui-widget-get g widget 'offset)))
        (glgui-widget-set! g widget 'offset (exact->inexact (max 0 (min maximum (+ offset delta))))))))

(define (expense-open-categories!)
  (let* ((options (expense-category-options (uiget 'type "Expense")))
         (selected (expense-current-category))
         (w (glgui-width-get)) (h (glgui-height-get)))
    (set! expense-picker-gui (make-glgui))
    (let ((g expense-picker-gui))
      (glgui-box g 0 0 w h expense-bg)
      (expense-label g 24 (- h 52) (- w 48) 28 "Choose category" heading_22.fnt expense-ink)
      (expense-label g 24 (- h 86) (- w 48) 24
        (string-append (uiget 'type "Expense") " categories") body_14.fnt expense-muted)
      (set! expense-list
        (glgui-list g 24 100 (- w 48) (- h 214) 58
          (map (lambda (category)
                 (lambda (g widget x y w h selected?)
                   (glgui:draw-text-left (+ x 16) (+ y 15) (- w 52) 26 category heading_16.fnt expense-ink)
                   (if (string=? category selected)
                       (glgui:draw-text-right x (+ y 15) (- w 16) 26 "Selected" body_12.fnt expense-mint))
                   (glgui:draw-box x y w 1 expense-bg))) options)
          (lambda (g widget . args)
            (let ((index (glgui-widget-get g widget 'current)))
              (if (and (>= index 0) (< index (length options)))
                  (expense-select-category! (list-ref options index)))))))
      (set! expense-list-gui g)
      (glgui-widget-set! g expense-list 'bgcol1 expense-panel)
      (glgui-widget-set! g expense-list 'bgcol2 expense-panel)
      (glgui-widget-set! g expense-list 'autohidebar #t)
      (glgui-widget-set! g expense-list 'scrollcolor expense-muted)
      (expense-button g 24 24 128 48 "Back" expense-panel expense-ink
        (lambda args (set! expense-view 'entry)))
      (expense-button g (- w 224) 24 92 48 "Up" expense-panel expense-muted
        (lambda args (expense-scroll-list! -1)))
      (expense-button g (- w 120) 24 96 48 "Down" expense-panel expense-muted
        (lambda args (expense-scroll-list! 1))))
    (set! expense-view 'categories)))

(main
  (lambda (w h)
    (if (not (file-exists? log:path)) (create-directory log:path))
    (log-reset!)
    (log-system "ExpenseTracker: initializing")
    (make-window 480 800)
    (glgui-orientation-set! GUI_PORTRAIT)
    (set! db (sqlite-open (string-append (system-directory) "/expense.sqlite")))
    (if (not db) (error "Cannot open expense database"))
    (expense-initialize-db!)
    (expense-show-view! 'overview)
    (log-system "ExpenseTracker: initialized"))
  (lambda (t x y)
    (cond
      ((and (= t EVENT_KEYPRESS) (= x EVENT_KEYESCAPE))
       (cond ((eq? expense-view 'categories) (set! expense-view 'entry))
             ((eq? expense-view 'entry)
              (cond ((glgui-widget-get entry-gui form 'keypad-on) (glgui:uiform-keypad-down))
                    ((eq? (glgui-widget-get entry-gui form 'page) 'delete)
                     (glgui-widget-set! entry-gui form 'page 'main)
                     (glgui-widget-set! entry-gui form 'nodemap '()))
                    (else (expense-show-view! expense-return-view))))
             ((eq? expense-view 'activity) (expense-show-view! 'overview))
             (else (terminate))))
      ((and (= t EVENT_KEYPRESS) (not (eq? expense-view 'entry))
            (or (= x EVENT_KEYUP) (= x EVENT_KEYDOWN)))
       (expense-scroll-list! (if (= x EVENT_KEYUP) -1 1)))
      (else
        (glgui-event (cond ((eq? expense-view 'entry) entry-gui)
                          ((eq? expense-view 'categories) expense-picker-gui)
                          (else gui)) t x y))))
  (lambda () (when db (sqlite-close db) (set! db #f)) #t)
  (lambda () (glgui-suspend))
  (lambda () (glgui-resume)))
