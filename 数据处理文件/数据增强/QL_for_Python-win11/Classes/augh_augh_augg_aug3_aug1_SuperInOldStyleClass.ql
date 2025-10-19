/**
 * @name Use of 'super' in old-style class
 * @description Detects calls to the built-in 'super' function within old-style classes, which do not support this mechanism.
 * @kind problem
 * @tags portability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/super-in-old-style
 */

import python

// Identifies super() calls in old-style classes where this mechanism is unsupported
predicate superCallInOldStyleClass(Call superCallNode) {
  exists(Function enclosingMethod, ClassObject hostClass |
    // Verify the call targets the built-in 'super' function
    superCallNode.getFunc().(Name).getId() = "super" and
    
    // Ensure the call occurs within a method/function scope
    superCallNode.getScope() = enclosingMethod and
    
    // Confirm the enclosing function is a method of a class
    enclosingMethod.getScope() = hostClass.getPyClass() and
    
    // Validate class analysis completed successfully
    not hostClass.failedInference() and
    
    // Verify the class is old-style (doesn't inherit from 'object')
    not hostClass.isNewStyle()
  )
}

// Identify all problematic super() calls violating old-style class constraints
from Call superCallViolation
where superCallInOldStyleClass(superCallViolation)
select superCallViolation, "'super()' will not work in old-style classes."