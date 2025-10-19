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

// Identifies invocations of super() within old-style class contexts
predicate superInvocationInOldStyleClass(Call superInvocation) {
  exists(Function parentFunction, ClassObject parentClass |
    // Check if the call is to the 'super' built-in function
    superInvocation.getFunc().(Name).getId() = "super" and
    // Ensure the super call is within a function/method
    superInvocation.getScope() = parentFunction and
    // Verify the function is a member of a class
    parentFunction.getScope() = parentClass.getPyClass() and
    // Confirm the class was successfully analyzed
    not parentClass.failedInference() and
    // Identify old-style classes (those not inheriting from object or other new-style classes)
    not parentClass.isNewStyle()
  )
}

// Query to find all problematic super() calls in old-style classes
from Call invalidSuperCall
where superInvocationInOldStyleClass(invalidSuperCall)
select invalidSuperCall, "'super()' will not work in old-style classes."