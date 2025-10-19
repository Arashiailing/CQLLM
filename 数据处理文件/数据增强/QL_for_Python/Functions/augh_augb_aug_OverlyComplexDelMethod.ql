/**
 * @name Overly complex `__del__` method
 * @description Identifies `__del__` methods with high cyclomatic complexity. The `__del__` special method in Python 
 *              is invoked during object destruction, which occurs at unpredictable times or might not happen at all. 
 *              Complex logic within these methods can cause performance issues and unpredictable behavior during 
 *              garbage collection cycles.
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

from FunctionValue delMethod
where 
  // Identify classes that define a __del__ method
  exists(ClassValue definingClass | 
    definingClass.declaredAttribute("__del__") = delMethod
  )
  // Evaluate if the __del__ method has excessive complexity
  and 
  delMethod.getScope().getMetrics().getCyclomaticComplexity() > 3
select delMethod, "Overly complex '__del__' method."