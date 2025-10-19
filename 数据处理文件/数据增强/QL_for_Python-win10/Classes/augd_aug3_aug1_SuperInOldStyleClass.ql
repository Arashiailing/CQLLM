/**
 * @name 'super' in old style class
 * @description Identifies super() calls in old-style classes where they are unsupported.
 * @kind problem
 * @tags portability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/super-in-old-style
 */

import python

// Detects super() calls occurring within old-style class definitions
predicate superCallInOldStyleClass(Call superCall) {
  exists(Function containerFunction, ClassObject containerClass |
    // Verify the call targets the 'super' function
    superCall.getFunc().(Name).getId() = "super" and
    // Ensure call is inside a function
    superCall.getScope() = containerFunction and
    // Verify function is class member
    containerFunction.getScope() = containerClass.getPyClass() and
    // Confirm class is successfully analyzed
    not containerClass.failedInference() and
    // Identify old-style classes (non-new-style)
    not containerClass.isNewStyle()
  )
}

// Query for problematic super() calls in old-style classes
from Call superCall
where superCallInOldStyleClass(superCall)
select superCall, "'super()' will not work in old-style classes."