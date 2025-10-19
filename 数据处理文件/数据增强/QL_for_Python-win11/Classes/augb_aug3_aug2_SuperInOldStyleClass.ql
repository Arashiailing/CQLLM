/**
 * @name 'super' in old style class
 * @description Detects usage of super() calls within old-style classes, which is unsupported.
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
 * Identifies super() function calls that occur within old-style class definitions.
 * Such calls are problematic because old-style classes do not support the super() mechanism.
 */
predicate problematicSuperUsageInLegacyClass(Call superCall) {
  // Verify the call targets the 'super' builtin function
  superCall.getFunc().(Name).getId() = "super" and
  // Ensure the call is properly nested within function and class scopes
  exists(Function enclosingFunction, ClassObject hostClass |
    // The super call must be inside a function
    superCall.getScope() = enclosingFunction and
    // That function must be defined inside a class
    enclosingFunction.getScope() = hostClass.getPyClass() and
    // The class must be successfully analyzed
    not hostClass.failedInference() and
    // Confirm this is an old-style (legacy) class
    not hostClass.isNewStyle()
  )
}

// Main query to find all problematic super() calls in old-style classes
from Call problematicSuperCall
// Filter for super() calls that violate the old-style class restriction
where problematicSuperUsageInLegacyClass(problematicSuperCall)
// Report the issue with appropriate error message
select problematicSuperCall, "'super()' will not work in old-style classes."