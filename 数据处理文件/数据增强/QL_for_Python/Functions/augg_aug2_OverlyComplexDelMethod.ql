/**
 * @name Overly complex `__del__` method
 * @description Identifies `__del__` methods that have high cyclomatic complexity.
 *              These special methods can be invoked at unpredictable times during
 *              garbage collection and should be implemented with minimal complexity
 *              to avoid potential issues with resource management and performance.
 * @kind problem
 * @tags efficiency
 *       maintainability
 *       complexity
 *       statistical
 *       non-attributable
 * @problem.severity recommendation
 * @sub-severity low
 * @precision high
 * @id py/overly-complex-delete
 */

import python

from FunctionValue delFunction
where
  exists(ClassValue ownerClass |
    // Confirm the method is the __del__ destructor of a class
    ownerClass.declaredAttribute("__del__") = delFunction and
    // Evaluate method complexity against threshold
    delFunction.getScope().getMetrics().getCyclomaticComplexity() > 3
  )
select delFunction, "Overly complex '__del__' method."