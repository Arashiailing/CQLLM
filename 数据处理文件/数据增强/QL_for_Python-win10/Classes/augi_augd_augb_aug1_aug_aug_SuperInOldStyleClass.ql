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
 * Identifies super() function calls within methods of legacy class definitions.
 * 
 * This predicate captures super() invocations that are destined to fail at runtime
 * because old-style classes lack the proper inheritance mechanisms required by super().
 */
predicate superCallInOldClass(Call superInvocation) {
  // Confirm the call targets Python's built-in super function
  superInvocation.getFunc().(Name).getId() = "super" and
  // Analyze the contextual environment of the super() invocation
  exists(Function methodWithinClass |
    // The super() call must be situated inside a method definition
    superInvocation.getScope() = methodWithinClass and
    // This method must be contained within an old-style class
    exists(ClassObject enclosingClass |
      // Establish the containment relationship between method and class
      methodWithinClass.getScope() = enclosingClass.getPyClass() and
      // Ensure the class type analysis completed successfully
      not enclosingClass.failedInference() and
      // Confirm the class follows old-style conventions (no inheritance from object)
      not enclosingClass.isNewStyle()
    )
  )
}

// Main query to detect problematic super() invocations
from Call faultySuperCall
// Apply filtering logic to isolate super() calls in old-style class contexts
where superCallInOldClass(faultySuperCall)
// Generate alert with informative message for each detected issue
select faultySuperCall, "'super()' will not work in old-style classes."