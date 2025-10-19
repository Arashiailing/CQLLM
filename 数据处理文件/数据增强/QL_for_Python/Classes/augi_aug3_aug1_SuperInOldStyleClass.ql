/**
 * @name 'super' in old style class
 * @description Detects super() calls in old-style classes where they are unsupported.
 * @kind problem
 * @tags portability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/super-in-old-style
 */

import python

// Identifies super() invocations within old-style class contexts
predicate superCallInOldStyleClass(Call superCall) {
  exists(Function parentFunction, ClassObject parentClass |
    // Verify the call targets the 'super' function
    superCall.getFunc().(Name).getId() = "super" and
    // Ensure call is inside a function
    superCall.getScope() = parentFunction and
    // Verify function is class member
    parentFunction.getScope() = parentClass.getPyClass() and
    // Confirm class is successfully analyzed
    not parentClass.failedInference() and
    // Identify old-style classes (non-new-style)
    not parentClass.isNewStyle()
  )
}

// Query for problematic super() invocations
from Call superCall
where superCallInOldStyleClass(superCall)
select superCall, "'super()' will not work in old-style classes."