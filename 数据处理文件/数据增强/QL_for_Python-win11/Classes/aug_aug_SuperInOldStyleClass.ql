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
predicate superCallInOldClass(Call superInvocation) {
  exists(Function methodDef, ClassObject enclosingClass |
    // Verify the call occurs within a method context
    superInvocation.getScope() = methodDef and
    // Ensure the method is defined inside a class
    methodDef.getScope() = enclosingClass.getPyClass() and
    // Confirm the class type was successfully inferred
    not enclosingClass.failedInference() and
    // Explicitly check for old-style class (non-new-style)
    not enclosingClass.isNewStyle() and
    // Validate the call targets the built-in super function
    superInvocation.getFunc().(Name).getId() = "super"
  )
}

// Query all call expressions
from Call callNode
// Filter super() calls within old-style classes
where superCallInOldClass(callNode)
// Report the issue with descriptive message
select callNode, "'super()' will not work in old-style classes."