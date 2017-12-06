

; The typed-define module exports syntax for an extended version of 'define',
; 'define*', that supports optional type annotations within the 'define*' form,
; after the name and before the body, e.g.
;
;     (define* (string-join strings delimiter)
;       :: (list-of string) string -> string
;       (if (null? strings) ""
;         (let* ([delim-length (string-length delimiter)]
;                [result-length (+ (reduce + (map string-length strings))
;                                  (* delim-length (- (length strings) 1)))]
;                [result (make-string result-length)])
;           (string-copy! result 0 (car strings))
;           (fold (lambda (item index)
;                   (string-copy! result index delimiter)
;                   (string-copy! result (+ index delim-length) item)
;                   (+ index delim-length (string-length item))
;                 (string-length (car strings))
;                 (cdr strings))
;           result)))

(module typed-define
  * ; export everything

  (import scheme chicken)

  (define-syntax define*
    ; A version of "define" that supports type annotation syntax, e.g.
    ;     
    ;     (define* (longer str1 str2)
    ;       :: string string -> string
    ;       (if (> (string-length str1) (string-length str2))
    ;         str1
    ;         str2))
    ;
    ;     (define* pi :: number 3.1415926)
    ;
    ;     (define* (long-lines) -> (list-of string)
    ;       (print "debug: long-lines was called")
    ;       (filter (lambda (line) (> (string-length line) 79))
    ;               (read-lines)))
    ;    
    ;     (define* (nothing-special)
    ;       (print "The type annotations are optional."))
    ;
    ;     (define* last-example "Even in this form, they're optional.")
    ;
    (syntax-rules (:: ->)
      
      ; regular definition with type
      [(define* name :: type value)
    
       (begin (: name type)
              (define name value))]
    
      ; regular definition without type
      [(define* name value)
    
       (define  name value)]
    
      ; function definition with type, no arguments
      [(define* (name) -> result-type
          body ...)
    
       (begin (: name (-> result-type))
              (define (name) body ...))]
    
      ; function definition with type, with arguments.
      ; Have to use a helper macro because you can't have something like:
      ;     :: arg-types ... -> result-type
      ; in a macro pattern.  The "..." always has to be at the end of a form.
      ; I don't want to require users to type:
      ;     :: (arg-types ...) -> result-type
      ; so, the define*-helper macro allows me to avoid the extra parentheses.
      [(define* (name args ...)
         :: arg1-type rest ...)
    
       (define*-helper (name args ...)
         (arg1-type) rest ...)]
  
      ; function definition without type.
      [(define* (name arg ...)
         body ...)
  
       (define  (name arg ...)
         body ...)]))
  
  (define-syntax define*-helper
    (syntax-rules (->)
  
      ; The final case.  We've consumed argument types (putting them into the
      ; arg-types list) until we reached the "->" which means all that remains
      ; is the return type and the body.
      [(define*-helper (name args ...)
         (arg-types ...) -> result-type
         body ...)
       
       (begin (: name (arg-types ... -> result-type))
              (define (name args ...)
                body ...))]
  
      ; The initial/intermediate case.  We're consuming argument types and
      ; placing them into the arg-types list.
      [(define*-helper (name args ...)
         (arg-types ...) next-arg-type rest ...)
  
       (define*-helper (name args ...)
         (arg-types ... next-arg-type) rest ...)])))

; MIT License
; 
; Copyright (c) 2017 David Goffredo
; 
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
; 
; The above copyright notice and this permission notice shall be included in
; all copies or substantial portions of the Software.
; 
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.
