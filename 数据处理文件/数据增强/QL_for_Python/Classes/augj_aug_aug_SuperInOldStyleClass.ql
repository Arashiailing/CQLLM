/**
 * @name 'super' in old style class
 * @description Detects unsupported super() usage in old-style classes where inheritance is not properly handled.
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
 * Identifies super() calls within old-style class methods.
 * 
 * This predicate captures super() invocations that will fail at runtime
 * because old-style classes lack the necessary inheritance mechanism.
 */
predicate superCallInOldClass(Call superCall) {
  // Verify the call targets the built-in super function
  superCall.getFunc().(Name).getId() = "super" and
  // Check if the call occurs within a method context
  exists(Function method, ClassObject cls |
    superCall.getScope() = method and
    // Ensure the method is defined inside a class
    method.getScope() = cls.getPyClass() and
    // Confirm the class type was successfully inferred
    not cls.failedInference() and
    // Explicitly check for old-style class (non-new-style)
    not cls.isNewStyle()
  )
}

// Query all call expressions
from Call superCallNode
// Filter super() calls within old-style classes
where superCallInOldClass(superCallNode)
// Report the issue with descriptive message
select superCallNode, "'super()' will not work in old-style classes."