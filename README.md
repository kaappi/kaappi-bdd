# kaappi-bdd

BDD (Behavior-Driven Development) test framework for
[Kaappi Scheme](https://kaappi-lang.org).

Write tests as specifications with `describe`, `context`, and `it` blocks.
Includes a matcher DSL, lifecycle hooks, and nested documentation-format output.

## Install

```
thottam install kaappi-bdd
```

## Quick Start

```scheme
(import (scheme base) (kaappi bdd))

(describe "string-append"
  (it "concatenates two strings"
    (expect (string-append "hello" " world") to-equal "hello world"))

  (context "with empty strings"
    (it "returns the other string"
      (expect (string-append "" "x") to-equal "x"))))

(run-specs)
```

Run:

```
kaappi --lib-path ./lib my-test.scm
```

Output:

```
string-append
  concatenates two strings  ok
  with empty strings
    returns the other string  ok

2 examples, 0 failures
```

## API

### Structure

- `(describe "name" body ...)` — group related specs
- `(context "name" body ...)` — alias for `describe`, conventionally used for
  "when/with" conditions
- `(it "name" body ...)` — a single spec (test case)
- `(xit "name" body ...)` — skip this spec (pending)
- `(xdescribe "name" body ...)` — skip this group
- `(pending)` / `(pending "reason")` — mark current spec as pending

### Matchers

```scheme
(expect actual matcher [args ...])
```

| Matcher | Checks |
|---------|--------|
| `to-equal expected` | `(equal? actual expected)` |
| `to-eqv expected` | `(eqv? actual expected)` |
| `to-be pred` | `(pred actual)` is truthy |
| `to-be-truthy` | `actual` is not `#f` |
| `to-be-falsy` | `actual` is `#f` |
| `to-be-a pred` | type check via predicate |
| `to-contain element` | member of list, string, or vector |
| `to-satisfy pred` | custom predicate |
| `to-be-close-to expected tolerance` | `(< (abs (- actual expected)) tolerance)` |
| `to-be-null` | `(null? actual)` |
| `to-be-greater-than n` | `(> actual n)` |
| `to-be-less-than n` | `(< actual n)` |
| `not-to-equal expected` | negation of `to-equal` |
| `not-to-contain element` | negation of `to-contain` |

### Error Expectations

```scheme
(it "raises on bad input"
  (expect-error (/ 1 0)))
```

### Hooks

```scheme
(describe "database"
  (before-all (connect-db!))
  (after-all (disconnect-db!))

  (before-each (begin-transaction!))
  (after-each (rollback-transaction!))

  (it "reads data" ...))
```

- `before-each` / `after-each` — run around every `it` in scope (cascades
  through nested `describe`/`context` blocks)
- `before-all` — runs once at the start of the enclosing group
- `after-all` — runs once at the end of the enclosing group

Hooks cascade: outer `before-each` runs before inner `before-each`. Outer
`after-each` runs after inner `after-each`.

### Running

```scheme
(run-specs)  ; prints summary, exits 1 on failure
```

## Output Format

Passing:
```
calculator
  addition
    adds two numbers  ok
    adds negative numbers  ok

2 examples, 0 failures
```

Failing:
```
calculator
  addition
    adds two numbers  FAIL

Failures:

  1) adds two numbers
     expected: 5
          got: 4

1 example, 1 failure
```

## License

MIT
