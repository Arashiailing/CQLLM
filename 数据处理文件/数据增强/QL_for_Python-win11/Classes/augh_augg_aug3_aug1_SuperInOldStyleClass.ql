/**
 * @name 'super' in old style class
 * @description Detects super() calls in old-style classes where they are unsupported.
 * @kind problem
 * @tags portability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/super-in-old-style
 */

import python

// This predicate identifies instances where the super() function is called within old-style classes.
// Old-style classes in Python are those that don't inherit from 'object' and lack support for
// the super() mechanism, leading to potential runtime errors.
predicate superCallInOldStyleClass(Call superCall) {
  exists(Function enclosingFunction, ClassObject parentClass |
    // The call must be to the built-in 'super' function
    superCall.getFunc().(Name).getId() = "super" and
    
    // The super() call must be inside a function/method
    superCall.getScope() = enclosingFunction and
    
    // The enclosing function must be a method of a class
    enclosingFunction.getScope() = parentClass.getPyClass() and
    
    // Class analysis must have been successful
    not parentClass.failedInference() and
    
    // The class must be an old-style class (not inheriting from object)
    not parentClass.isNewStyle()
  )
}

// Main query that identifies all problematic super() calls in old-style classes
from Call problematicSuperCall
where superCallInOldStyleClass(problematicSuperCall)
select problematicSuperCall, "'super()' will not work in old-style classes."