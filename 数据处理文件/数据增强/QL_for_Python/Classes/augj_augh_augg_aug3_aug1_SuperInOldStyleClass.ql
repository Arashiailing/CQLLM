/**
 * @name 'super' in old style class
 * @description Identifies super() function calls within old-style Python classes, which do not support this mechanism.
 * @kind problem
 * @tags portability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/super-in-old-style
 */

import python

// This predicate identifies calls to the super() function within old-style classes.
// In Python, old-style classes are defined as those that do not inherit from 'object'.
// These classes lack support for the super() mechanism, which can result in runtime errors.
predicate superCallInOldStyleClass(Call superInvocation) {
  exists(Function containingFunction, ClassObject hostClass |
    // Verify the call targets the built-in 'super' function
    superInvocation.getFunc().(Name).getId() = "super" and
    
    // Ensure the super() call is located within a function or method
    superInvocation.getScope() = containingFunction and
    
    // Confirm the enclosing function is a method belonging to a class
    containingFunction.getScope() = hostClass.getPyClass() and
    
    // Verify that class analysis was completed successfully and the class is old-style
    not hostClass.failedInference() and
    not hostClass.isNewStyle()
  )
}

// Primary query that detects all super() calls in old-style classes that will cause issues
from Call invalidSuperCall
where superCallInOldStyleClass(invalidSuperCall)
select invalidSuperCall, "'super()' will not work in old-style classes."