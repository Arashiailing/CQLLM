/**
 * @name 'super' in old style class
 * @description Identifies improper usage of super() calls within legacy Python classes
 *              that do not support new-style inheritance mechanisms.
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
 * Locates super() function calls that are problematic because they occur
 * within methods of old-style classes, which lack proper inheritance support.
 * 
 * Such calls will result in runtime errors since old-style classes do not
 * implement the MRO (Method Resolution Order) required by super().
 */
predicate superCallInOldClass(Call superCallExpr) {
  exists(Function methodContext, ClassObject parentClass |
    // The super() call must be inside a method definition
    superCallExpr.getScope() = methodContext and
    // The method must be defined within a class
    methodContext.getScope() = parentClass.getPyClass() and
    // The class type must be successfully inferred by the analysis
    not parentClass.failedInference() and
    // The class must be an old-style class (not inheriting from 'object')
    not parentClass.isNewStyle() and
    // The call must be to the built-in 'super' function
    superCallExpr.getFunc().(Name).getId() = "super"
  )
}

// Main query to find all problematic super() calls
from Call problematicCall
// Apply our predicate to filter for super() calls in old-style classes
where superCallInOldClass(problematicCall)
// Generate the alert with an appropriate error message
select problematicCall, "'super()' will not work in old-style classes."