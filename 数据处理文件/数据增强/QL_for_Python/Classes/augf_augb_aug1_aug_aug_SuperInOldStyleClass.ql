/**
 * @name 'super' in old style class
 * @description Detects incorrect usage of super() in legacy class definitions that lack proper inheritance support.
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
 * This predicate finds super() invocations that will fail at runtime
 * because old-style classes don't have proper inheritance mechanisms.
 */
predicate superCallInOldClass(Call superCall) {
  // Verify the call is to the built-in super function
  superCall.getFunc().(Name).getId() = "super" and
  // Check the context of the call - must be within a method of an old-style class
  exists(Function methodWithinClass |
    superCall.getScope() = methodWithinClass and
    // Find the enclosing class of the method
    exists(ClassObject legacyClass |
      methodWithinClass.getScope() = legacyClass.getPyClass() and
      // Ensure the class type was properly determined
      not legacyClass.failedInference() and
      // Confirm the class follows old-style conventions (not inheriting from object)
      not legacyClass.isNewStyle()
    )
  )
}

// Main query to find problematic super() calls in old-style classes
from Call problematicSuperCall
where superCallInOldClass(problematicSuperCall)
// Report the identified issue with an appropriate message
select problematicSuperCall, "'super()' will not work in old-style classes."