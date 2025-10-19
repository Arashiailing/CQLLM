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
 * Locates super() function calls within methods of old-style classes.
 * 
 * This predicate identifies super() invocations that will cause runtime errors
 * since old-style classes lack proper inheritance mechanisms required by super().
 */
predicate superCallInOldClass(Call superCall) {
  // Ensure the call targets the built-in super function
  superCall.getFunc().(Name).getId() = "super" and
  // Validate the call context is within a method of an old-style class
  exists(Function methodDef |
    // The super call must be inside a method
    superCall.getScope() = methodDef and
    // The method must be inside an old-style class
    exists(ClassObject parentClass |
      methodDef.getScope() = parentClass.getPyClass() and
      // Verify the class type was properly determined
      not parentClass.failedInference() and
      // Confirm the class follows old-style conventions (not inheriting from object)
      not parentClass.isNewStyle()
    )
  )
}

// Main query to identify problematic super() calls in old-style classes
from Call problematicSuperCall
// Apply filter to find super() calls specifically within old-style classes
where superCallInOldClass(problematicSuperCall)
// Generate alert with descriptive message
select problematicSuperCall, "'super()' will not work in old-style classes."