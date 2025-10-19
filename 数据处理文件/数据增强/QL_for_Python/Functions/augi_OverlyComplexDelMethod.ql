/**
 * @name Overly complex `__del__` method
 * @description The `__del__` method may be called at arbitrary times, perhaps never called at all, and should be kept simple.
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

from FunctionValue deleteMethod
where
  exists(ClassValue ownerClass | 
    ownerClass.declaredAttribute("__del__") = deleteMethod
  ) and
  deleteMethod.getScope().getMetrics().getCyclomaticComplexity() > 3
select deleteMethod, "Overly complex '__del__' method."