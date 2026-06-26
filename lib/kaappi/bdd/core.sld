(define-library (kaappi bdd core)
  (import (scheme base) (scheme write)
          (kaappi bdd matchers)
          (kaappi bdd reporter))
  (export describe context it xit xdescribe
          before-each after-each before-all after-all
          expect expect-error pending
          run-specs
          ;; Macro helper procedures (prefixed with % to signal internal use)
          %enter-describe! %exit-describe!
          %register-before-hook! %register-after-hook! %register-after-all-hook!
          %run-example %skip-spec! %skip-group!
          %is-framework-condition? %check-error-raised)
  (begin
    (define-record-type <spec-failure>
      (make-spec-failure message)
      spec-failure?
      (message spec-failure-message))

    (define-record-type <spec-pending>
      (make-spec-pending reason)
      spec-pending?
      (reason spec-pending-reason))

    ;; Context: #(description before-each-hooks after-each-hooks after-all-hooks)
    (define (make-context desc)
      (vector desc '() '() '()))

    (define (context-description ctx) (vector-ref ctx 0))

    (define (context-add-before! ctx hook)
      (vector-set! ctx 1 (cons hook (vector-ref ctx 1))))

    (define (context-add-after! ctx hook)
      (vector-set! ctx 2 (cons hook (vector-ref ctx 2))))

    (define (context-add-after-all! ctx hook)
      (vector-set! ctx 3 (cons hook (vector-ref ctx 3))))

    (define (context-before-each ctx) (vector-ref ctx 1))
    (define (context-after-each ctx) (vector-ref ctx 2))
    (define (context-after-all ctx) (vector-ref ctx 3))

    (define %context-stack '())

    (define (collect-before-hooks)
      (let loop ((stack (reverse %context-stack)) (hooks '()))
        (if (null? stack)
            hooks
            (loop (cdr stack)
                  (append hooks (reverse (context-before-each (car stack))))))))

    (define (collect-after-hooks)
      (let loop ((stack %context-stack) (hooks '()))
        (if (null? stack)
            hooks
            (loop (cdr stack)
                  (append hooks (reverse (context-after-each (car stack))))))))

    (define (obj->string val)
      (let ((p (open-output-string)))
        (write val p)
        (get-output-string p)))

    (define (error->string exn)
      (if (error-object? exn)
          (let ((msg (error-object-message exn)))
            (if (null? (error-object-irritants exn))
                msg
                (string-append msg ": "
                  (obj->string (error-object-irritants exn)))))
          (string-append "non-error raised: " (obj->string exn))))

    ;; Exported macro helpers

    (define (%enter-describe! desc)
      (let ((ctx (make-context desc)))
        (report-group-begin desc)
        (set! %context-stack (cons ctx %context-stack))
        ctx))

    (define (%exit-describe! ctx)
      (for-each (lambda (h) (h)) (context-after-all ctx))
      (set! %context-stack (cdr %context-stack))
      (report-group-end))

    (define (%register-before-hook! thunk)
      (context-add-before! (car %context-stack) thunk))

    (define (%register-after-hook! thunk)
      (context-add-after! (car %context-stack) thunk))

    (define (%register-after-all-hook! thunk)
      (context-add-after-all! (car %context-stack) thunk))

    (define (%run-example desc thunk)
      (let ((before-hooks (collect-before-hooks))
            (after-hooks (collect-after-hooks)))
        (guard (exn
                ((spec-failure? exn)
                 (report-spec-fail desc (spec-failure-message exn)))
                ((spec-pending? exn)
                 (report-spec-pending desc))
                (#t
                 (report-spec-fail desc (error->string exn))))
          (for-each (lambda (h) (h)) before-hooks)
          (thunk)
          (for-each (lambda (h) (h)) after-hooks)
          (report-spec-pass desc))))

    (define (%skip-spec! desc)
      (report-spec-pending desc))

    (define (%skip-group! desc)
      (report-group-begin desc)
      (report-spec-pending "(entire group skipped)")
      (report-group-end))

    (define (%is-framework-condition? exn)
      (or (spec-failure? exn) (spec-pending? exn)))

    (define (%check-error-raised raised)
      (when (not raised)
        (raise (make-spec-failure
          "expected an error to be raised, but none was"))))

    ;; Public API procedures

    (define (expect actual matcher . args)
      (let ((result (apply matcher actual args)))
        (when (not (match-result-pass? result))
          (raise (make-spec-failure (match-result-message result))))))

    (define (pending . args)
      (raise (make-spec-pending
        (if (null? args) "pending" (car args)))))

    (define (run-specs)
      (report-summary)
      (when (> %fail-count 0)
        (exit 1)))

    ;; Macros — only reference exported helper procedures

    (define-syntax describe
      (syntax-rules ()
        ((_ desc body ...)
         (let ((ctx (%enter-describe! desc)))
           body ...
           (%exit-describe! ctx)))))

    (define-syntax context
      (syntax-rules ()
        ((_ desc body ...)
         (let ((ctx (%enter-describe! desc)))
           body ...
           (%exit-describe! ctx)))))

    (define-syntax it
      (syntax-rules ()
        ((_ desc body ...)
         (%run-example desc (lambda () body ...)))))

    (define-syntax xit
      (syntax-rules ()
        ((_ desc body ...)
         (%skip-spec! desc))))

    (define-syntax xdescribe
      (syntax-rules ()
        ((_ desc body ...)
         (%skip-group! desc))))

    (define-syntax before-each
      (syntax-rules ()
        ((_ body ...)
         (%register-before-hook! (lambda () body ...)))))

    (define-syntax after-each
      (syntax-rules ()
        ((_ body ...)
         (%register-after-hook! (lambda () body ...)))))

    (define-syntax before-all
      (syntax-rules ()
        ((_ body ...)
         (begin body ...))))

    (define-syntax after-all
      (syntax-rules ()
        ((_ body ...)
         (%register-after-all-hook! (lambda () body ...)))))

    (define-syntax expect-error
      (syntax-rules ()
        ((_ body ...)
         (let ((raised #f))
           (guard (exn
                   ((%is-framework-condition? exn) (raise exn))
                   (#t (set! raised #t)))
             body ...)
           (%check-error-raised raised)))))))
