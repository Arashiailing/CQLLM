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

// Identifies super() calls within old-style class contexts
predicate superCallInOldStyleClass(Call superCall) {
  exists(Function containingFunction, ClassObject containingClass |
    // Verify the call targets the 'super' function
    superCall.getFunc().(Name).getId() = "super" and
    // Ensure call is inside a function
    superCall.getScope() = containingFunction and
    // Verify function is class member
    containingFunction.getScope() = containingClass.getPyClass() and
    // Confirm class is successfully analyzed
    not containingClass.failedInference() and
    // Identify old-style classes (non-new-style)
    not containingClass.isNewStyle()
  )
}

// Query for problematic super() calls
from Call problematicSuperCall
where superCallInOldStyleClass(problematicSuperCall)
select problematicSuperCall, "'super()' will not work in old-style classes."