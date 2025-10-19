/**
 * @name 'super' in old style class
 * @description Identifies improper usage of super() in legacy class definitions that lack proper inheritance support.
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
 * Locates super() function calls within methods of old-style classes.
 * 
 * This predicate identifies super() invocations that are destined to fail at runtime
 * due to the absence of proper inheritance mechanisms in old-style class definitions.
 */
predicate superCallInOldClass(Call superCall) {
  exists(Function method, ClassObject hostClass |
    // Establish the call is within a method's scope
    superCall.getScope() = method and
    // Verify the method is contained within a class
    method.getScope() = hostClass.getPyClass() and
    // Ensure the class type was successfully determined
    not hostClass.failedInference() and
    // Check that the class follows old-style conventions (not new-style)
    not hostClass.isNewStyle() and
    // Confirm the call is to the built-in super function
    superCall.getFunc().(Name).getId() = "super"
  )
}

// Query all call expressions
from Call problematicCall
// Filter to find super() calls specifically within old-style classes
where superCallInOldClass(problematicCall)
// Report the identified issue with an appropriate message
select problematicCall, "'super()' will not work in old-style classes."