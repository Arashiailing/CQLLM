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
predicate superCallInOldClass(Call superInvocation) {
  // First, verify the call is to the built-in super function
  superInvocation.getFunc().(Name).getId() = "super" and
  // Then check the context of the call
  exists(Function classMethod |
    // The call must be inside a method
    superInvocation.getScope() = classMethod and
    // The method must be inside an old-style class
    exists(ClassObject enclosingClass |
      classMethod.getScope() = enclosingClass.getPyClass() and
      // Verify the class type was properly determined
      not enclosingClass.failedInference() and
      // Confirm the class follows old-style conventions (not inheriting from object)
      not enclosingClass.isNewStyle()
    )
  )
}

// Main query to find problematic super() calls
from Call faultySuperCall
// Filter for super() calls specifically within old-style classes
where superCallInOldClass(faultySuperCall)
// Report the identified issue with an appropriate message
select faultySuperCall, "'super()' will not work in old-style classes."