;; MIT License
;;
;; Copyright (c) 2025 Rabina Poudyal
;; Copyright (c) 2025 Benson Muite
;; Copyright (c) 2026 Bonface Kabiru
;;
;; Permission is hereby granted, free of charge, to any person obtaining a copy
;; of this software and associated documentation files (the "Software"), to deal
;; in the Software without restriction, including without limitation the rights
;; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;; copies of the Software, and to permit persons to whom the Software is
;; furnished to do so, subject to the following conditions:
;;
;; The above copyright notice and this permission notice shall be included in all
;; copies or substantial portions of the Software.
;;
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;; SOFTWARE.

(use-modules (haunt asset)
             (haunt page)
             (haunt builder blog)
             (haunt builder atom)
             (haunt builder assets)
	         (haunt builder flat-pages)
             (haunt builder redirects)
             (haunt builder rss)
	         (haunt html)
	         (haunt reader)
             (haunt reader skribe)
             (haunt reader texinfo)
             (haunt reader commonmark)
             (haunt site)
	         (haunt utils))

(define test-theme
  (theme #:name "test-theme"
         #:layout
         (lambda (site title body)
           `((doctype "html")
             (head
              (meta (@ (charset "utf-8")))
              (title ,title))
             (body
              (div (@ (class "container"))
                    ,body))))))

(define (static-page title file-name body)
  (lambda (site posts)
    (make-page file-name
               (with-layout test-theme site title body)
               sxml->html)))

(define home-page
  (static-page "Expense Tracker" "index.html"
	       `(
		 (h1 "Expense Tracker")
		 (p "budget yourself"))))
		 

(site #:title "GeoTrace"
      #:domain "bonfacenjuguna.github.io"
      #:build-directory "build"
      #:default-metadata
      '((author . "Bonface Kabiru"))
      #:readers (list commonmark-reader texinfo-reader skribe-reader sxml-reader html-reader)
      #:builders (list (blog)
		       home-page
                       (atom-feed)
                       (atom-feeds-by-tag)
                       (rss-feed)
		       (static-directory "images")))
