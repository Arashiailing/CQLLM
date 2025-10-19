/**
 * @name Use of 'super' in old-style class
 * @description Identifies invocations of the built-in 'super' function within old-style classes, which lack support for this mechanism.
 * @kind problem
 * @tags portability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/super-in-old-style
 */

import python

// Detects super() function calls within old-style class contexts where such functionality is not supported
predicate superCallInOldStyleClass(Call superInvocation) {
  exists(Function parentMethod, ClassObject targetClass |
    // The call must be to the built-in 'super' function
    superInvocation.getFunc().(Name).getId() = "super" and
    
    // The super() call must be inside a method/function
    superInvocation.getScope() = parentMethod and
    
    // The enclosing function must be a method of a class
    parentMethod.getScope() = targetClass.getPyClass() and
    
    // Ensure class analysis was successful
    not targetClass.failedInference() and
    
    // Confirm the class is old-style (does not inherit from 'object')
    not targetClass.isNewStyle()
  )
}

// Find all super() calls that violate old-style class constraints
from Call invalidSuperCall
where superCallInOldStyleClass(invalidSuperCall)
select invalidSuperCall, "'super()' will not work in old-style classes."