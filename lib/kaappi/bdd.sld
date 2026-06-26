(define-library (kaappi bdd)
  (import (kaappi bdd core)
          (kaappi bdd matchers))
  (export describe context it xit xdescribe
          before-each after-each before-all after-all
          expect expect-error pending
          run-specs
          ;; Matchers
          to-equal to-eqv to-be
          to-be-truthy to-be-falsy
          to-be-a to-contain to-satisfy
          to-be-close-to to-be-null
          to-be-greater-than to-be-less-than
          not-to-equal not-to-contain
          ;; Macro helpers (needed at expansion sites)
          %enter-describe! %exit-describe!
          %register-before-hook! %register-after-hook! %register-after-all-hook!
          %run-example %skip-spec! %skip-group!
          %is-framework-condition? %check-error-raised))
