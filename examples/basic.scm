(import (scheme base) (kaappi bdd))

(describe "string-append"
  (it "concatenates two strings"
    (expect (string-append "hello" " world") to-equal "hello world"))

  (it "handles empty strings"
    (expect (string-append "" "x") to-equal "x")
    (expect (string-append "x" "") to-equal "x"))

  (context "with multiple arguments"
    (it "concatenates all"
      (expect (string-append "a" "b" "c") to-equal "abc"))))

(describe "arithmetic"
  (it "adds numbers"
    (expect (+ 2 3) to-equal 5))

  (it "handles negative results"
    (expect (- 3 5) to-equal -2))

  (it "multiplies"
    (expect (* 6 7) to-equal 42))

  (context "division"
    (it "divides evenly"
      (expect (/ 10 2) to-equal 5))

    (it "raises on division by zero"
      (expect-error (/ 1 0)))))

(describe "list operations"
  (it "creates lists"
    (expect (list 1 2 3) to-equal '(1 2 3)))

  (it "finds elements"
    (expect '(a b c) to-contain 'b))

  (it "handles empty lists"
    (expect '() to-be-null)))

(run-specs)
