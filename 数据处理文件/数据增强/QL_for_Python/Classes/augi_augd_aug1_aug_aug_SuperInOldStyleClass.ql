/**
 * @name 'super' in old style class
 * @description Identifies incorrect usage of super() in traditional class definitions that lack modern inheritance support.
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
 * Identifies super() function calls within methods of old-style classes.
 * 
 * These calls are problematic because old-style classes do not support the inheritance
 * mechanisms required by super(), leading to runtime errors.
 */
predicate superCallInOldClass(Call superCall) {
  exists(Function methodInClass, ClassObject oldStyleClass |
    // Verify the call targets the built-in super function
    superCall.getFunc().(Name).getId() = "super" and
    // Ensure the call occurs within a method's scope
    superCall.getScope() = methodInClass and
    // Confirm the method is defined within a class
    methodInClass.getScope() = oldStyleClass.getPyClass() and
    // Validate successful class type inference
    not oldStyleClass.failedInference() and
    // Identify old-style classes (non-new-style)
    not oldStyleClass.isNewStyle()
  )
}

// Query all call expressions
from Call superCall
// Filter for super() calls specifically within old-style classes
where superCallInOldClass(superCall)
// Report the identified issue with an appropriate message
select superCall, "'super()' will not work in old-style classes."