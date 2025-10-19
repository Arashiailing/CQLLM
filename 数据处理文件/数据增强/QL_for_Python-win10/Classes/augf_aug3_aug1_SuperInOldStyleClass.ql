/**
 * @name 'super' call in legacy class
 * @description Identifies super() invocations within legacy-style classes where such functionality is not supported.
 * @kind problem
 * @tags portability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/super-in-old-style
 */

import python

// Identifies super() invocations within legacy-style class contexts
predicate superCallInOldStyleClass(Call superInvocation) {
  exists(Function parentFunction, ClassObject parentClass |
    // Verify the invocation targets the 'super' function
    superInvocation.getFunc().(Name).getId() = "super" and
    // Ensure invocation is inside a function
    superInvocation.getScope() = parentFunction and
    // Verify function is class member
    parentFunction.getScope() = parentClass.getPyClass() and
    // Confirm class is successfully analyzed
    not parentClass.failedInference() and
    // Identify legacy-style classes (non-new-style)
    not parentClass.isNewStyle()
  )
}

// Query for problematic super() invocations
from Call invalidSuperCall
where superCallInOldStyleClass(invalidSuperCall)
select invalidSuperCall, "'super()' will not work in old-style classes."