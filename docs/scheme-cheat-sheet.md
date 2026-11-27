# Scheme cheat sheet

Use this alongside the [runnable practice file](examples/scheme-practice.scm).
Examples here use core Scheme supported by Gambit unless marked otherwise.
Framework functions such as `main`, `uiget` and `glgui-widget-set!` are not part
of the Scheme language itself.

## 1. Start with the distinction

| Name | Meaning in this workshop |
|---|---|
| Scheme | The programming language |
| Gambit | The Scheme implementation: interpreter, compiler and runtime |
| LambdaNative | Framework and build tools used to create native apps |
| glGUI | LambdaNative's GUI widgets and drawing tools |
| SQLite | The embedded database storing the app's transactions |

Suggested explanation: “Scheme expresses our rules; LambdaNative connects those
rules to a window, input events, assets and the phone or desktop.”

## 2. Run Scheme without building an app

In a terminal:

```sh
gsi
```

At the REPL, type an expression and press Enter. Do not type the REPL prompt.
REPL means read, evaluate, print, loop. If it waits for more input, check for a
missing closing parenthesis or quotation mark.

```scheme
(+ 2 3)                        ; => 5
(* 4 (+ 2 3))                  ; => 20
(display "Jambo, Lions!")
(newline)
(exit)                         ; Gambit: leave the interpreter
```

Run the prepared examples from the repository root:

```sh
gsi docs/examples/scheme-practice.scm
```

Comments begin with `;`. Parentheses determine grouping; indentation helps
humans see that grouping. Expressions can span many lines.

## 3. Read expressions from the outside inward

```scheme
(- 1000 (+ 150 50))             ; => 800
```

1. The outer operation is subtraction.
2. Its first argument is `1000`.
3. Its second argument is the result of `(+ 150 50)`.
4. Compute `1000 - 200`.

Ordinary procedure calls use `(procedure argument ...)`. Special forms such as
`if`, `define` and `quote` have their own evaluation rules. Do not teach that
every parenthesized form evaluates all of its children.

## 4. Values and names

```scheme
42                             ; exact integer
1/2                            ; exact rational number
12.5                           ; normally an inexact number
"Income"                       ; string
'Income                        ; symbol
#t                             ; true
#f                             ; false
#\a                            ; character
'()                            ; empty list
```

Only `#f` is false in a conditional. `0`, `""` and `'()` are true.
Check an empty list using `null?`, not by treating it as false.

```scheme
(define currency "KES")
(define balance-cents 100000)
(set! balance-cents (- balance-cents 1250))
balance-cents                  ; => 98750
```

`define` introduces a binding. `set!` changes an existing binding. A `!` in a
procedure name conventionally signals mutation; it is not an automatic language
feature. Likewise, names ending in `?` conventionally ask a yes/no question.

## 5. Procedures and callbacks

```scheme
(define (balance income expenses)
  (- income expenses))

(balance 1000 250)              ; => 750

(define add-tax
  (lambda (amount) (* amount 1.16)))
```

`lambda` creates a procedure. `define` with a parameter list is a convenient way
to give a procedure a name. Procedures can be passed around as values.

```scheme
(define (make-adder n)
  (lambda (x) (+ x n)))

((make-adder 10) 5)             ; => 15
```

The inner procedure remembers `n`: this is a closure. In the app, a list callback
remembers which transaction rows it was built from.

```scheme
(lambda () (display "Clicked")) ; accepts no arguments
(lambda args (display "Clicked")) ; accepts any number; args is a list
```

The app often uses `(lambda args ...)` for widget callbacks where it does not
need the arguments supplied by the GUI.

## 6. Conditional expressions

```scheme
(if (> 1250 0) "Valid" "Invalid")

(cond
  ((not amount) "Enter a number")
  ((<= amount 0) "Enter a positive number")
  (else "Ready"))
```

The second example assumes `amount` is already bound to a number or `#f`.
`cond` tries clauses in order. `and` and `or` short-circuit and return values,
not necessarily booleans:

```scheme
(and #t 1250)                  ; => 1250
(or #f "Fallback")             ; => "Fallback"
```

That explains the app's `(or (sqlite-query db sql) (error ...))`: return the query
result unless it is `#f`. A successful write returns `'()`, which is true.

`begin` groups a sequence where a single expression is expected:

```scheme
(if #t
    (begin (display "Saved") (newline) #t)
    #f)
```

## 7. Local bindings: let and let*

```scheme
(let ((income 1000)
      (expenses 250))
  (- income expenses))         ; => 750

(let* ((text "12.50")
       (amount (string->number text)))
  (and amount (> amount 0)))    ; => #t
```

`let` initializers do not see the new bindings from the same `let`. `let*`
introduces them sequentially. This matters in `expense-save-form!`: category
state is checked before reading the custom category name.

## 8. Lists and transaction rows

```scheme
(define categories '("Salary" "Business" "Other"))
(car categories)               ; => "Salary"
(cdr categories)               ; => ("Business" "Other")
(cadr categories)              ; => "Business"
(list-ref categories 2)        ; => "Other"; indexing starts at zero
(length categories)            ; => 3
(null? '())                    ; => #t
(cons "Freelance" categories)  ; prepends to a new list
(member "Other" categories)    ; => ("Other"), a true value
```

`car` takes the first element of a pair. `cdr` takes the rest. `cadr` is
`car` of `cdr`; `caddr` takes the third element. Calling `car` on an empty list
is an error.

Current app row shape:

```scheme
'("17" "Expense" "1250" "Bus fare" "Transport" "2026-10-29 15:10:00")
;; ID     type       cents  description category    creation timestamp
```

IDs and cents in query results are strings deliberately; the app converts them
when it needs numbers. They are not formatted display amounts.

## 9. map, for-each and apply

```scheme
(map (lambda (n) (* n 2)) '(1 2 3)) ; => (2 4 6)
(apply + '(100 20 5))              ; => 125
(for-each (lambda (s) (display s) (newline)) '("Income" "Expense"))
```

Use `map` to transform a list into a new list. Use `for-each` for effects; do not
rely on its return value. `apply` passes the elements of a list as arguments.
The app maps database rows to row-drawing procedures.

## 10. Quotation and quasiquotation

```scheme
(+ 1 2)                        ; => 3: execute
'(+ 1 2)                       ; => (+ 1 2): data
(quote (+ 1 2))                ; same as the preceding expression

(define title "Personal Finance")
`(label text ,title)            ; => (label text "Personal Finance")
```

A backtick creates a template. A comma evaluates a value inside that template.
This is why uiform declarations can combine data such as `align left` with live
Scheme procedures. A symbol like `'main` can identify a page, while `"main"`
is a string; they are different values.

## 11. Strings, conversion and equality

```scheme
(string-append "KES " "12.50")  ; => "KES 12.50"
(number->string 1250)           ; => "1250"
(string->number "12.50")        ; numeric value, typically inexact
(string->number "oops")         ; => #f
(string=? "Income" "Income")    ; => #t
(= 1250 1250)                  ; numeric comparison
(eq? 'overview 'overview)       ; symbol identity
(equal? '(1 2) '(1 2))          ; structural comparison
```

Use `string=?` for strings, `=` for numbers and `equal?` for compound values.
Do not rely on `eq?` to compare separately created strings or arbitrary numbers.

## 12. Recursion and exact money

```scheme
(define (sum-cents xs)
  (let loop ((remaining xs) (total 0))
    (if (null? remaining)
        total
        (loop (cdr remaining) (+ total (car remaining))))))

(sum-cents '(10 20 1250))       ; => 1280
```

Named `let` defines a local looping procedure. The recursive call here is in
tail position: nothing remains to compute after it returns. Scheme supports
proper tail calls.

For money, distinguish syntax from application validation. Scheme accepts
`1/2` and `1e2` as numbers, but this app's decimal-text parser rejects them.
The app stores `"12.50"` as the exact integer `1250` cents. It does not depend on
binary floating-point addition to calculate balances.

## 13. Gambit facilities used in the app

These are implementation/framework facilities, not a promise of portability
across every Scheme implementation:

```scheme
(define preferences (make-table))
(table-set! preferences 'currency "KES")
(table-ref preferences 'currency "Unknown")

(with-exception-catcher
  (lambda (e) "Could not complete the operation")
  (lambda () (error "Example failure")))
```

In production-facing code, record useful diagnostic information and give the
user a readable message. In the app, query failures are raised, caught by the
save/delete handlers, logged, and returned as a form message.

## 14. Common beginner errors

| Symptom | Check |
|---|---|
| REPL waits for more input | Parentheses or string quotes are unclosed |
| Unbound variable | Spelling, scope, missing quote, or an app API used in plain `gsi` |
| Tried to call a list | Extra parentheses: `((1 2 3))` attempts a procedure call |
| Number operation fails | A form field contains a string; validate/convert it |
| Empty query result crashes | Check for a pair before calling `car`/`caar` |
| Condition unexpectedly true | Only `#f` is false, including when the value is `'()` |
| Definition is visible in one place only | Inspect the surrounding `let`/procedure scope |
| Widget state changes unexpectedly | Trace mutation and callback order |

## 15. Practice prompts with answers

1. Predict `(- 500 (+ 100 50))`. Answer: `350`.
2. Write a procedure that subtracts expenses from income.
   Answer: `(define (balance i e) (- i e))`.
3. Get the category from the sample row above. Answer: `(list-ref row 4)`.
4. Add 10 cents and 20 cents. Answer: `(+ 10 20)` => `30`.
5. Why is `(if '() "yes" "no")` => `"yes"`? The empty list is true.
6. Why does a callback use `lambda`? It describes work to do later, when an event occurs.
7. Why does `(member ...)` work in an `if` even when it returns a list? Any non-`#f` value is true.

References: [Gambit and its manual](https://gambitscheme.org/),
[Scheme language reports](https://scheme-reports.org/).
