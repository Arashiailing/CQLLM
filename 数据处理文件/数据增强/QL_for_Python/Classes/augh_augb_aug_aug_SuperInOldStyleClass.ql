/**
 * @name 'super' in old style class
 * @description Identifies super() calls in old-style classes that lack proper inheritance support
 * @kind problem
 * @tags portability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/super-in-old-style
 */

import python

// Query targeting super() invocations that will fail in old-style classes
from Call superInvocation
where 
  // Check for existence of a method within an old-style class
  exists(Function classMethod, ClassObject legacyClass |
    // The super call must be scoped within a method
    superInvocation.getScope() = classMethod and
    // The method must be defined inside a class context
    classMethod.getScope() = legacyClass.getPyClass() and
    // Verify the class was properly inferred during analysis
    not legacyClass.failedInference() and
    // Confirm this is an old-style class (non-new-style)
    not legacyClass.isNewStyle() and
    // Ensure the call is targeting the built-in super function
    superInvocation.getFunc().(Name).getId() = "super"
  )
// Report the problematic super() call with an informative message
select superInvocation, "'super()' will not work in old-style classes."