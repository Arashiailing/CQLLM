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

// This predicate identifies super() function calls that are located within old-style class definitions,
// which do not support the super() mechanism. In Python, old-style classes don't inherit from 'object'
// and have different method resolution behavior.
predicate superCallInOldStyleClass(Call superInvocation) {
  exists(Function containerFunction, ClassObject containerClass |
    // Check if the call is to the 'super' built-in function
    superInvocation.getFunc().(Name).getId() = "super" and
    // Verify that the super() call is inside a function/method
    superInvocation.getScope() = containerFunction and
    // Ensure that the containing function is a method of a class
    containerFunction.getScope() = containerClass.getPyClass() and
    // Confirm that the class analysis was successful
    not containerClass.failedInference() and
    // Identify old-style classes (classes that don't inherit from object or other new-style classes)
    not containerClass.isNewStyle()
  )
}

// Main query that finds all problematic super() calls in old-style classes
from Call invalidSuperCall
where superCallInOldStyleClass(invalidSuperCall)
select invalidSuperCall, "'super()' will not work in old-style classes."