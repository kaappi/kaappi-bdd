(define-library (kaappi bdd matchers)
  (import (scheme base) (scheme write))
  (export make-match-result match-result-pass? match-result-message
          to-equal to-eqv to-be
          to-be-truthy to-be-falsy
          to-be-a to-contain to-satisfy
          to-be-close-to to-be-null
          to-be-greater-than to-be-less-than
          not-to-equal not-to-contain)
  (begin
    (define (make-match-result pass? message)
      (cons pass? message))

    (define (match-result-pass? r) (car r))
    (define (match-result-message r) (cdr r))

    (define (obj->string val)
      (let ((p (open-output-string)))
        (write val p)
        (get-output-string p)))

    (define (to-equal actual expected)
      (if (equal? actual expected)
          (make-match-result #t "")
          (make-match-result #f
            (string-append "expected: " (obj->string expected) "\n"
                           "     got: " (obj->string actual)))))

    (define (to-eqv actual expected)
      (if (eqv? actual expected)
          (make-match-result #t "")
          (make-match-result #f
            (string-append "expected (eqv?): " (obj->string expected) "\n"
                           "            got: " (obj->string actual)))))

    (define (to-be actual pred)
      (if (pred actual)
          (make-match-result #t "")
          (make-match-result #f
            (string-append "expected " (obj->string actual)
                           " to satisfy predicate"))))

    (define (to-be-truthy actual)
      (if actual
          (make-match-result #t "")
          (make-match-result #f "expected a truthy value, got #f")))

    (define (to-be-falsy actual)
      (if (not actual)
          (make-match-result #t "")
          (make-match-result #f
            (string-append "expected #f, got " (obj->string actual)))))

    (define (to-be-a actual pred)
      (if (pred actual)
          (make-match-result #t "")
          (make-match-result #f
            (string-append (obj->string actual)
                           " is not of the expected type"))))

    (define (to-satisfy actual pred)
      (if (pred actual)
          (make-match-result #t "")
          (make-match-result #f
            (string-append "expected " (obj->string actual)
                           " to satisfy predicate"))))

    (define (str-contains? haystack needle)
      (let ((hlen (string-length haystack))
            (nlen (string-length needle)))
        (if (> nlen hlen)
            #f
            (let loop ((i 0))
              (cond
                ((> (+ i nlen) hlen) #f)
                ((string=? (substring haystack i (+ i nlen)) needle) #t)
                (else (loop (+ i 1))))))))

    (define (to-contain actual element)
      (cond
        ((string? actual)
         (if (and (string? element) (str-contains? actual element))
             (make-match-result #t "")
             (make-match-result #f
               (string-append "expected " (obj->string actual)
                              " to contain " (obj->string element)))))
        ((list? actual)
         (if (member element actual)
             (make-match-result #t "")
             (make-match-result #f
               (string-append "expected " (obj->string actual)
                              " to contain " (obj->string element)))))
        ((vector? actual)
         (let loop ((i 0))
           (cond
             ((= i (vector-length actual))
              (make-match-result #f
                (string-append "expected " (obj->string actual)
                               " to contain " (obj->string element))))
             ((equal? (vector-ref actual i) element)
              (make-match-result #t ""))
             (else (loop (+ i 1))))))
        (else
         (make-match-result #f "to-contain requires a string, list, or vector"))))

    (define (to-be-close-to actual expected tolerance)
      (if (< (abs (- actual expected)) tolerance)
          (make-match-result #t "")
          (make-match-result #f
            (string-append "expected " (obj->string actual)
                           " to be within " (obj->string tolerance)
                           " of " (obj->string expected)))))

    (define (to-be-null actual)
      (if (null? actual)
          (make-match-result #t "")
          (make-match-result #f
            (string-append "expected '(), got " (obj->string actual)))))

    (define (to-be-greater-than actual expected)
      (if (> actual expected)
          (make-match-result #t "")
          (make-match-result #f
            (string-append "expected " (obj->string actual)
                           " > " (obj->string expected)))))

    (define (to-be-less-than actual expected)
      (if (< actual expected)
          (make-match-result #t "")
          (make-match-result #f
            (string-append "expected " (obj->string actual)
                           " < " (obj->string expected)))))

    (define (not-to-equal actual expected)
      (if (not (equal? actual expected))
          (make-match-result #t "")
          (make-match-result #f
            (string-append "expected " (obj->string actual)
                           " to not equal " (obj->string expected)))))

    (define (not-to-contain actual element)
      (let ((r (to-contain actual element)))
        (if (match-result-pass? r)
            (make-match-result #f
              (string-append "expected " (obj->string actual)
                             " to not contain " (obj->string element)))
            (make-match-result #t ""))))))
