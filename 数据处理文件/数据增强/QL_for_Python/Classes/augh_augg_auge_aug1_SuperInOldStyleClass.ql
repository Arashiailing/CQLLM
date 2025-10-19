/**
 * @name 'super' in old style class
 * @description Detects super() invocations within legacy class definitions that cause runtime failures.
 * @kind problem
 * @tags portability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/super-in-old-style
 */

import python

// Predicate identifying super() calls within legacy class contexts
predicate superCallInOldStyleClass(Call superInvocation) {
  // Verify the invocation targets the 'super' built-in function
  superInvocation.getFunc().(Name).getId() = "super" and
  // Ensure the call occurs within a function nested inside a class
  exists(Function enclosingFunction, ClassObject enclosingClass |
    superInvocation.getScope() = enclosingFunction and
    enclosingFunction.getScope() = enclosingClass.getPyClass() and
    // Validate the class is properly resolved and uses legacy style
    not enclosingClass.failedInference() and
    not enclosingClass.isNewStyle()
  )
}

// Query to locate all problematic super() invocations
from Call problematicSuperInvocation
where superCallInOldStyleClass(problematicSuperInvocation)
// Report the problematic call with diagnostic message
select problematicSuperInvocation, "'super()' will not work in old-style classes."