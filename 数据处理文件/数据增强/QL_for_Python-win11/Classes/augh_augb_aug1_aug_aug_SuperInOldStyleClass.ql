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
  exists(Name funcName | 
    funcName = superCall.getFunc() and 
    funcName.getId() = "super"
  ) and
  // Check the call occurs within a method of an old-style class
  exists(Function method |
    superCall.getScope() = method and
    exists(ClassObject legacyClass |
      method.getScope() = legacyClass.getPyClass() and
      // Ensure class type was properly determined
      not legacyClass.failedInference() and
      // Confirm class follows old-style conventions (no object inheritance)
      not legacyClass.isNewStyle()
    )
  )
}

// Main query to identify problematic super() calls
from Call problematicSuperCall
// Filter for super() calls specifically within old-style classes
where superCallInOldClass(problematicSuperCall)
// Report the identified issue with an appropriate message
select problematicSuperCall, "'super()' will not work in old-style classes."