/**
 * @name 'super' in old style class
 * @description Detects unsupported super() usage in old-style classes
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
 * Identifies invalid super() calls within old-style class contexts
 * @param callNode - The super() call node to validate
 */
predicate isOldStyleClassSuperCall(Call callNode) {
  // Verify the call targets the super function
  callNode.getFunc().(Name).getId() = "super" and
  // Ensure call occurs within a function scope
  exists(Function enclosingFunction |
    callNode.getScope() = enclosingFunction and
    // Verify function is defined within a class
    exists(ClassObject definingClass |
      enclosingFunction.getScope() = definingClass.getPyClass() and
      // Confirm class inference succeeded
      not definingClass.failedInference() and
      // Validate class uses old-style inheritance
      not definingClass.isNewStyle()
    )
  )
}

// Identify all problematic super() calls in old-style classes
from Call invalidSuperCall
// Filter calls that violate old-style class constraints
where isOldStyleClassSuperCall(invalidSuperCall)
// Report findings with diagnostic message
select invalidSuperCall, "'super()' will not work in old-style classes."