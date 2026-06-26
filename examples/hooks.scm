(import (scheme base) (kaappi bdd))

(define db '())

(describe "user database"
  (before-each
    (set! db '(("alice" . "admin") ("bob" . "user"))))

  (after-each
    (set! db '()))

  (it "starts with two users"
    (expect (length db) to-equal 2))

  (it "contains alice"
    (expect (assoc "alice" db) to-be-truthy))

  (context "after adding a user"
    (before-each
      (set! db (cons '("carol" . "user") db)))

    (it "has three users"
      (expect (length db) to-equal 3))

    (it "contains the new user"
      (expect (assoc "carol" db) to-be-truthy))

    (context "with nested context"
      (before-each
        (set! db (cons '("dave" . "admin") db)))

      (it "has four users from cascading hooks"
        (expect (length db) to-equal 4)))))

(run-specs)
