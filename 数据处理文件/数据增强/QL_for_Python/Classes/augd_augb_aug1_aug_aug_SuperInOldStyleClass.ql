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
 * Locates super() function invocations within methods of legacy class definitions.
 * 
 * This predicate identifies super() calls that are destined to fail at execution time
 * due to the absence of proper inheritance mechanisms in old-style classes.
 */
predicate superCallInOldClass(Call superCall) {
  // Validate that the invocation targets the built-in super function
  superCall.getFunc().(Name).getId() = "super" and
  // Examine the surrounding context of the super() call
  exists(Function methodInClass |
    // The super() call must be located within a method definition
    superCall.getScope() = methodInClass and
    // This method must be nested inside an old-style class
    exists(ClassObject parentClass |
      // Establish the relationship between method and containing class
      methodInClass.getScope() = parentClass.getPyClass() and
      // Ensure the class type inference was successful
      not parentClass.failedInference() and
      // Verify the class uses old-style conventions (doesn't inherit from object)
      not parentClass.isNewStyle()
    )
  )
}

// Primary query to identify problematic super() invocations
from Call problematicSuperCall
// Apply filter to isolate super() calls within old-style class contexts
where superCallInOldClass(problematicSuperCall)
// Generate alert with descriptive message for each identified issue
select problematicSuperCall, "'super()' will not work in old-style classes."