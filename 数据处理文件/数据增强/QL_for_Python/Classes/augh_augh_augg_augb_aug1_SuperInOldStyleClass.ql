/**
 * @name 'super' in old style class
 * @description Detects usage of super() in old-style classes (classes not inheriting from object),
 *              which causes runtime errors in Python.
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
 * Determines if a super() call is located within an old-style class.
 * Old-style classes are those that do not inherit from object (Python 2.x style).
 * Using super() in old-style classes will raise a runtime error.
 */
predicate isSuperCallInOldStyleClass(Call superCall) {
  exists(Function parentFunction, ClassObject parentClass |
    // Verify the call is to the super function
    superCall.getFunc().(Name).getId() = "super" and
    // Check the call context: within a function inside a class
    superCall.getScope() = parentFunction and
    parentFunction.getScope() = parentClass.getPyClass() and
    // Validate class properties
    not parentClass.failedInference() and
    not parentClass.isNewStyle()
  )
}

// Identify all super() calls used within old-style classes
from Call invalidSuperCall
where isSuperCallInOldStyleClass(invalidSuperCall)
// Output the problematic code and error message
select invalidSuperCall, "'super()' will not work in old-style classes."