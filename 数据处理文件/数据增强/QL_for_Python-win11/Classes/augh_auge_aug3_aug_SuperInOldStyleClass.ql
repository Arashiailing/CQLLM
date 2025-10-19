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
 * This query identifies super() calls within old-style class methods.
 * Such calls lead to runtime errors because old-style classes don't support
 * the super() mechanism for method resolution order.
 */
from Call superInvocation
where 
  exists(Function enclosingMethod, ClassObject legacyClass |
    // Verify super call occurs within a method definition
    superInvocation.getScope() = enclosingMethod and
    // Ensure method is defined inside a class context
    enclosingMethod.getScope() = legacyClass.getPyClass() and
    // Confirm class type inference was successful
    not legacyClass.failedInference() and
    // Identify old-style classes (non-new-style classes)
    not legacyClass.isNewStyle() and
    // Validate the call targets the built-in super function
    superInvocation.getFunc().(Name).getId() = "super"
  )
select superInvocation, "'super()' will not work in old-style classes."