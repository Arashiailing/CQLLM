/**
 * @name Overly complex `__del__` method
 * @description Detects `__del__` methods with excessive complexity since
 *              these special methods may be invoked at unpredictable times
 *              and should be kept simple.
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
  exists(ClassValue containerClass |
    // Check if the method is defined as __del__ in a class
    containerClass.declaredAttribute("__del__") = deleteMethod and
    // Verify the complexity threshold is exceeded
    deleteMethod.getScope().getMetrics().getCyclomaticComplexity() > 3
  )
select deleteMethod, "Overly complex '__del__' method."