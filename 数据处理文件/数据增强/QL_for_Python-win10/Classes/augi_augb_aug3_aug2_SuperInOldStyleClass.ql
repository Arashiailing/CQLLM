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
predicate problematicSuperUsageInLegacyClass(Call superInvocation) {
  // Verify the call targets the 'super' builtin function
  superInvocation.getFunc().(Name).getId() = "super" and
  // Ensure the call is properly nested within function and class scopes
  exists(Function containingFunction, ClassObject legacyClass |
    // The super call must be inside a function
    superInvocation.getScope() = containingFunction and
    // That function must be defined inside a class
    containingFunction.getScope() = legacyClass.getPyClass() and
    // The class must be successfully analyzed
    not legacyClass.failedInference() and
    // Confirm this is an old-style (legacy) class
    not legacyClass.isNewStyle()
  )
}

// Main query to find all problematic super() calls in old-style classes
from Call problematicSuperInvocation
// Filter for super() calls that violate the old-style class restriction
where problematicSuperUsageInLegacyClass(problematicSuperInvocation)
// Report the issue with appropriate error message
select problematicSuperInvocation, "'super()' will not work in old-style classes."