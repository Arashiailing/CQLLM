/**
 * @name Overly complex `__del__` method
 * @description Identifies Python classes with `__del__` methods that have high cyclomatic complexity.
 *              The `__del__` method is invoked during object destruction, which can occur at
 *              unpredictable times or be skipped in certain scenarios. Overly complex `__del__` methods
 *              can cause performance issues and erratic behavior during garbage collection.
 *              Best practice suggests keeping these special methods straightforward.
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

from FunctionValue destructorMethod, ClassValue definingClass
where
  // Verify that the method is the __del__ destructor of the class
  definingClass.declaredAttribute("__del__") = destructorMethod and
  // Check if the method's cyclomatic complexity exceeds the threshold of 3
  destructorMethod.getScope().getMetrics().getCyclomaticComplexity() > 3
select destructorMethod, "Overly complex '__del__' method."