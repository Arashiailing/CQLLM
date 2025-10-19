/**
 * @name 'super' in old style class
 * @description Identifies super() calls within old-style classes which result in runtime errors.
 * @kind problem
 * @tags portability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/super-in-old-style
 */

import python

// Predicate to identify super() calls that occur within old-style class contexts
predicate superCallInOldStyleClass(Call superCall) {
  // Verify that the call is to a function named "super"
  superCall.getFunc().(Name).getId() = "super" and
  // Ensure the call is inside a function which is itself inside a class
  exists(Function containingFunction, ClassObject containingClass |
    superCall.getScope() = containingFunction and
    containingFunction.getScope() = containingClass.getPyClass() and
    // Confirm the class is properly inferred and is an old-style class
    not containingClass.failedInference() and
    not containingClass.isNewStyle()
  )
}

// Main query to find all problematic super() calls
from Call problematicSuperCall
// Filter for super() calls in old-style classes
where superCallInOldStyleClass(problematicSuperCall)
// Output the problematic call with an explanatory message
select problematicSuperCall, "'super()' will not work in old-style classes."