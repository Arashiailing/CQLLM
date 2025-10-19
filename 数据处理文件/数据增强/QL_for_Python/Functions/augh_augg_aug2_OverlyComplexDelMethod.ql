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

from FunctionValue destructorMethod
where
  // Verify the method serves as a class destructor
  exists(ClassValue definingClass | 
    definingClass.declaredAttribute("__del__") = destructorMethod
  ) and
  // Check if complexity exceeds safety threshold
  destructorMethod.getScope().getMetrics().getCyclomaticComplexity() > 3
select destructorMethod, "Overly complex '__del__' method."