/**
 * @name 'super' in old style class
 * @description Detects usage of super() calls within old-style classes where inheritance mechanism is not supported
 * @kind problem
 * @tags portability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/super-in-old-style
 */

import python

// Main query targeting all function call expressions
from Call superInvocation
where 
  // Check if the call is within a method definition
  exists(Function methodDef, ClassObject legacyClass |
    superInvocation.getScope() = methodDef and
    // Verify the method is contained within a class body
    methodDef.getScope() = legacyClass.getPyClass() and
    // Ensure the class analysis was successful
    not legacyClass.failedInference() and
    // Identify old-style classes (those not inheriting from object)
    not legacyClass.isNewStyle() and
    // Confirm the call is to Python's built-in super function
    superInvocation.getFunc().(Name).getId() = "super"
  )
// Output the finding with appropriate error message
select superInvocation, "'super()' will not work in old-style classes."