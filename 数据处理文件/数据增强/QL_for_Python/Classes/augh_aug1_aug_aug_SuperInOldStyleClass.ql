/**
 * @name 'super' in old style class
 * @description Detects incorrect usage of super() in legacy class definitions that don't support proper inheritance.
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
 * Identifies super() function invocations within methods of old-style classes.
 * 
 * This predicate finds super() calls that will cause runtime failures
 * because old-style classes lack the necessary inheritance infrastructure.
 */
predicate superCallInOldClass(Call superInvocation) {
  exists(Function classMethod, ClassObject enclosingClass |
    // Verify the call is inside a method
    superInvocation.getScope() = classMethod and
    // Ensure the method belongs to a class
    classMethod.getScope() = enclosingClass.getPyClass() and
    // Confirm the class type was properly inferred
    not enclosingClass.failedInference() and
    // Check if the class uses old-style conventions (not inheriting from object)
    not enclosingClass.isNewStyle() and
    // Validate the call targets the built-in super function
    superInvocation.getFunc().(Name).getId() = "super"
  )
}

// Query all call expressions
from Call faultySuperCall
// Filter to identify super() calls specifically in old-style classes
where superCallInOldClass(faultySuperCall)
// Report the detected issue with an appropriate message
select faultySuperCall, "'super()' will not work in old-style classes."