/**
 * @name 'super' in old style class
 * @description Identifies super() calls in old-style classes where they are unsupported.
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
 * Detects super() calls that occur within old-style class definitions.
 * In Python, old-style classes do not support the super() function,
 * which is designed to work with new-style classes only.
 */
predicate superCallInOldStyleClass(Call superInvocation) {
  exists(Function enclosingFunction, ClassObject enclosingClass |
    // The call must be to the 'super' built-in function
    superInvocation.getFunc().(Name).getId() = "super" and
    // The super() call must be inside a function (typically a method)
    superInvocation.getScope() = enclosingFunction and
    // The function containing the super() call must be a member of a class
    enclosingFunction.getScope() = enclosingClass.getPyClass() and
    // The class must be successfully analyzed by CodeQL
    not enclosingClass.failedInference() and
    // The class must be an old-style class (not inheriting from object)
    not enclosingClass.isNewStyle()
  )
}

// Main query that finds all problematic super() calls in old-style classes
from Call superInvocation
where superCallInOldStyleClass(superInvocation)
select superInvocation, "'super()' will not work in old-style classes."