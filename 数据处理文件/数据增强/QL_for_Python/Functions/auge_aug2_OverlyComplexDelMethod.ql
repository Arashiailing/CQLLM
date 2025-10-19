/**
 * @name Overly complex `__del__` method
 * @description Identifies `__del__` methods with high cyclomatic complexity.
 *              These special methods execute at unpredictable times during
 *              object lifecycle and should remain simple to avoid performance issues.
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
  exists(ClassValue cls |
    // Confirm method is defined as __del__ within a class
    cls.declaredAttribute("__del__") = delMethod and
    // Verify complexity exceeds safe threshold
    delMethod.getScope().getMetrics().getCyclomaticComplexity() > 3
  )
select delMethod, "Overly complex '__del__' method."