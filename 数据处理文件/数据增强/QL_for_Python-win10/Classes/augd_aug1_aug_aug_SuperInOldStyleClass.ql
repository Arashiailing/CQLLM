/**
 * @name 'super' in old style class
 * @description Detects incorrect usage of super() in traditional class definitions that don't support modern inheritance.
 * @kind problem
 * @tags portability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/super-in-old-style
 */

import python

/**
 * Finds super() function calls inside methods of old-style classes.
 * 
 * This predicate identifies super() calls that will cause runtime errors
 * because old-style classes lack proper inheritance mechanisms required by super().
 */
predicate superCallInOldClass(Call superInvocation) {
  exists(Function classMethod, ClassObject parentClass |
    // Verify the call is to the built-in super function
    superInvocation.getFunc().(Name).getId() = "super" and
    // Establish the call is within a method's scope
    superInvocation.getScope() = classMethod and
    // Verify the method is contained within a class
    classMethod.getScope() = parentClass.getPyClass() and
    // Ensure the class type was successfully determined
    not parentClass.failedInference() and
    // Check that the class follows old-style conventions (not new-style)
    not parentClass.isNewStyle()
  )
}

// Query all call expressions
from Call invalidSuperCall
// Filter for super() calls specifically within old-style classes
where superCallInOldClass(invalidSuperCall)
// Report the identified issue with an appropriate message
select invalidSuperCall, "'super()' will not work in old-style classes."