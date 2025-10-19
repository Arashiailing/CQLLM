/**
 * @name Overly complex `__del__` method
 * @description Identifies Python classes with `__del__` methods that have high cyclomatic complexity.
 *              The `__del__` method is invoked during object destruction, a process that can be
 *              unpredictable or might not happen at all in certain scenarios. Complex logic within
 *              `__del__` methods can cause performance issues and unpredictable behavior during
 *              garbage collection. It's advisable to keep these special methods simple.
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
  // Find all __del__ methods with high cyclomatic complexity
  exists(ClassValue containingClass |
    // Check if the method is the class's __del__ method
    containingClass.declaredAttribute("__del__") = delMethod
  ) and
  // Verify the method's cyclomatic complexity exceeds the threshold
  delMethod.getScope().getMetrics().getCyclomaticComplexity() > 3
select delMethod, "Overly complex '__del__' method."