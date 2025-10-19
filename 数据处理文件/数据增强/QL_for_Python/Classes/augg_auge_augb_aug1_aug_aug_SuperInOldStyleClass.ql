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
 * Identifies super() invocations within methods of legacy classes.
 * 
 * This predicate captures super() calls that will trigger runtime errors
 * due to missing inheritance mechanisms in old-style class definitions.
 */
predicate superCallInOldClass(Call superInvocation) {
  // Verify the call targets Python's built-in super function
  exists(Name superFunc | 
    superFunc.getId() = "super" and
    superInvocation.getFunc() = superFunc
  ) and
  // Ensure the call occurs within a method context
  exists(Function methodContext |
    superInvocation.getScope() = methodContext and
    // Validate the method belongs to an old-style class
    exists(ClassObject legacyClass |
      methodContext.getScope() = legacyClass.getPyClass() and
      // Confirm class type inference succeeded
      not legacyClass.failedInference() and
      // Verify class follows old-style conventions (no object inheritance)
      not legacyClass.isNewStyle()
    )
  )
}

// Primary query to detect problematic super() calls in legacy classes
from Call faultySuperCall
// Filter for super() calls specifically within old-style class methods
where superCallInOldClass(faultySuperCall)
// Generate alert with descriptive error message
select faultySuperCall, "'super()' will not work in old-style classes."