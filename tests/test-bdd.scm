(import (scheme base) (kaappi bdd))

;;; Self-tests for kaappi-bdd

;; State for hook tests
(define hook-counter 0)
(define after-counter 0)
(define nested-log '())

(describe "describe"
  (it "creates a test group"
    (expect #t to-be-truthy))

  (context "with nested context"
    (it "supports nesting"
      (expect 1 to-equal 1))))

(describe "matchers"
  (context "to-equal"
    (it "passes for equal values"
      (expect 42 to-equal 42)
      (expect "hello" to-equal "hello")
      (expect '(1 2 3) to-equal '(1 2 3)))

    (it "passes for nested structures"
      (expect '((a . 1) (b . 2)) to-equal '((a . 1) (b . 2)))))

  (context "to-eqv"
    (it "compares with eqv?"
      (expect 42 to-eqv 42)
      (expect #t to-eqv #t)
      (expect #\a to-eqv #\a)))

  (context "to-be"
    (it "applies a predicate"
      (expect 42 to-be number?)
      (expect "hi" to-be string?)))

  (context "to-be-truthy"
    (it "passes for truthy values"
      (expect 1 to-be-truthy)
      (expect "yes" to-be-truthy)
      (expect '() to-be-truthy)))

  (context "to-be-falsy"
    (it "passes for #f"
      (expect #f to-be-falsy)))

  (context "to-be-a"
    (it "checks type predicates"
      (expect 42 to-be-a number?)
      (expect "hi" to-be-a string?)
      (expect '(1) to-be-a pair?)))

  (context "to-contain"
    (it "works with lists"
      (expect '(1 2 3) to-contain 2))

    (it "works with strings"
      (expect "hello world" to-contain "world"))

    (it "works with vectors"
      (expect (vector 'a 'b 'c) to-contain 'b)))

  (context "to-be-close-to"
    (it "checks numeric proximity"
      (expect 3.14 to-be-close-to 3.14159 0.01)))

  (context "to-be-null"
    (it "passes for empty list"
      (expect '() to-be-null)))

  (context "to-be-greater-than"
    (it "compares numbers"
      (expect 5 to-be-greater-than 3)))

  (context "to-be-less-than"
    (it "compares numbers"
      (expect 3 to-be-less-than 5)))

  (context "to-satisfy"
    (it "applies custom predicate"
      (expect 42 to-satisfy even?)))

  (context "not-to-equal"
    (it "passes for unequal values"
      (expect 1 not-to-equal 2)
      (expect "a" not-to-equal "b")))

  (context "not-to-contain"
    (it "passes when element is absent"
      (expect '(1 2 3) not-to-contain 4)
      (expect "hello" not-to-contain "xyz"))))

(describe "expect-error"
  (it "passes when an error is raised"
    (expect-error (error "boom")))

  (it "passes for division by zero"
    (expect-error (/ 1 0)))

  (it "passes for type errors"
    (expect-error (+ 1 "not a number"))))

(describe "before-each"
  (before-each (set! hook-counter (+ hook-counter 1)))

  (it "runs before specs"
    (expect hook-counter to-equal 1))

  (it "runs before every spec"
    (expect hook-counter to-equal 2)))

(describe "after-each"
  (after-each (set! after-counter (+ after-counter 1)))

  (it "has not run yet during first spec"
    (expect after-counter to-equal 0))

  (it "ran after the first spec"
    (expect after-counter to-equal 1)))

(describe "nested hooks"
  (before-each (set! nested-log (cons 'outer nested-log)))

  (context "inner group"
    (before-each (set! nested-log (cons 'inner nested-log)))

    (it "runs outer then inner before-each"
      (expect (car nested-log) to-equal 'inner)
      (expect (cadr nested-log) to-equal 'outer))))

(describe "pending specs"
  (xit "is a pending spec"
    (expect 1 to-equal 2))

  (it "can use pending inside a spec"
    (pending "not implemented yet")))

(describe "multiple expects in one spec"
  (it "all must pass"
    (expect 1 to-equal 1)
    (expect 2 to-equal 2)
    (expect 3 to-equal 3)))

(run-specs)
