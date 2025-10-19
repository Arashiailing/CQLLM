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

// Query expression targeting all function calls
from Call superCall
where 
  // Verify the call occurs within a method context
  exists(Function method, ClassObject oldClass |
    superCall.getScope() = method and
    // Ensure the method is defined inside a class
    method.getScope() = oldClass.getPyClass() and
    // Confirm the class type was successfully inferred
    not oldClass.failedInference() and
    // Explicitly check for old-style class (non-new-style)
    not oldClass.isNewStyle() and
    // Validate the call targets the built-in super function
    superCall.getFunc().(Name).getId() = "super"
  )
// Report the issue with descriptive message
select superCall, "'super()' will not work in old-style classes."