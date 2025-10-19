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
predicate superCallInOldStyleClass(Call superCallNode) {
  exists(Function enclosingFunction, ClassObject enclosingClass |
    // Verify the call targets the 'super' function
    superCallNode.getFunc().(Name).getId() = "super" and
    // Ensure call is inside a function
    superCallNode.getScope() = enclosingFunction and
    // Verify function is class member
    enclosingFunction.getScope() = enclosingClass.getPyClass() and
    // Confirm class is successfully analyzed
    not enclosingClass.failedInference() and
    // Identify old-style classes (non-new-style)
    not enclosingClass.isNewStyle()
  )
}

// Query for problematic super() calls
from Call problematicSuperCall
where superCallInOldStyleClass(problematicSuperCall)
select problematicSuperCall, "'super()' will not work in old-style classes."