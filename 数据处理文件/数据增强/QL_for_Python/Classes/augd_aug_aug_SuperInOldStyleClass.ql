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
  exists(Function method, ClassObject cls |
    // Context: call is inside a method
    superCall.getScope() = method and
    // Context: method is defined inside a class
    method.getScope() = cls.getPyClass() and
    // Class type was successfully inferred
    not cls.failedInference() and
    // Class is old-style (not new-style)
    not cls.isNewStyle() and
    // Call targets the built-in super function
    superCall.getFunc().(Name).getId() = "super"
  )
}

// Find all super() calls in old-style classes
from Call superCallExpr
where superCallInOldClass(superCallExpr)
select superCallExpr, "'super()' will not work in old-style classes."