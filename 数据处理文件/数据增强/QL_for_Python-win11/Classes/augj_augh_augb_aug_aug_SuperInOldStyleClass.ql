/**
 * @name 'super' in old style class
 * @description Detects super() function calls within old-style classes which do not support proper inheritance mechanisms
 * @kind problem
 * @tags portability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/super-in-old-style
 */

import python

// Query identifies super() calls that are incompatible with old-style class inheritance
from Call superCall
where 
  // Define the context: a method within an old-style class
  exists(Function methodInClass, ClassObject oldStyleClass |
    // Establish the relationship: super call is inside a method
    superCall.getScope() = methodInClass and
    // Establish the relationship: method is inside a class
    methodInClass.getScope() = oldStyleClass.getPyClass() and
    // Ensure the class was successfully analyzed
    not oldStyleClass.failedInference() and
    // Verify the class uses old-style inheritance (not new-style)
    not oldStyleClass.isNewStyle() and
    // Confirm the call is to Python's built-in super function
    superCall.getFunc().(Name).getId() = "super"
  )
// Output the problematic super() call with an explanatory message
select superCall, "'super()' will not work in old-style classes."