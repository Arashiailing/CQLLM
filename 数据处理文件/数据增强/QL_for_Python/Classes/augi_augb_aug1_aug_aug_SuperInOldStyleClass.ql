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
 * Locates instances where the super() function is invoked within methods of old-style classes.
 * 
 * This predicate identifies super() calls that are destined to fail during execution
 * due to the absence of proper inheritance mechanisms in old-style class definitions.
 */
predicate superCallInOldClass(Call superCall) {
  // Confirm the invocation targets the built-in super function
  superCall.getFunc().(Name).getId() = "super" and
  // Validate the calling context
  exists(Function methodInsideClass |
    // Ensure the super call occurs within a method
    superCall.getScope() = methodInsideClass and
    // Verify the method is contained within an old-style class
    exists(ClassObject parentClass |
      methodInsideClass.getScope() = parentClass.getPyClass() and
      // Check that the class type analysis was successful
      not parentClass.failedInference() and
      // Determine the class follows old-style patterns (not inheriting from object)
      not parentClass.isNewStyle()
    )
  )
}

// Primary query to identify problematic super() invocations
from Call problematicSuperInvocation
where superCallInOldClass(problematicSuperInvocation)
select problematicSuperInvocation, "'super()' will not work in old-style classes."