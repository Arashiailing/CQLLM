/**
 * @name 'super' in old style class
 * @description Identifies super() invocations within old-style class contexts where they are not supported.
 * @kind problem
 * @tags portability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/super-in-old-style
 */

import python

// Locates super() calls within old-style class definitions
predicate superCallInOldStyleClass(Call superCallNode) {
  exists(Function enclosingFunction, ClassObject enclosingClass |
    // Verify the call targets the 'super' function
    superCallNode.getFunc().(Name).getId() = "super" and
    // Ensure the call is inside a function
    superCallNode.getScope() = enclosingFunction and
    // Verify the function is a class member
    enclosingFunction.getScope() = enclosingClass.getPyClass() and
    // Confirm the class is successfully analyzed
    not enclosingClass.failedInference() and
    // Identify old-style classes (non-new-style)
    not enclosingClass.isNewStyle()
  )
}

// Query for problematic super() invocations
from Call problematicSuperCall
where superCallInOldStyleClass(problematicSuperCall)
select problematicSuperCall, "'super()' will not work in old-style classes."