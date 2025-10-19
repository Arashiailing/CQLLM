/**
 * @name 'super' in old style class
 * @description Detects usage of super() in old-style classes which causes runtime errors.
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
 * This pattern leads to runtime errors in Python as old-style classes
 * don't support the super() mechanism for method resolution.
 */
predicate isSuperCallInOldStyleClass(Call superCall) {
  exists(Function method, ClassObject classObj |
    // Verify super call occurs within a method definition
    superCall.getScope() = method and
    // Ensure method is defined inside a class context
    method.getScope() = classObj.getPyClass() and
    // Confirm class type inference was successful
    not classObj.failedInference() and
    // Identify old-style classes (non-new-style classes)
    not classObj.isNewStyle() and
    // Validate the call targets the built-in super function
    superCall.getFunc().(Name).getId() = "super"
  )
}

from Call superCallExpr
where isSuperCallInOldStyleClass(superCallExpr)
select superCallExpr, "'super()' will not work in old-style classes."