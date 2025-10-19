/**
 * @name Overly complex `__del__` method
 * @description This query identifies Python `__del__` methods with high cyclomatic complexity.
 *              The `__del__` method is invoked during object destruction, a process that
 *              can occur at unpredictable times or may be skipped entirely in certain scenarios.
 *              Methods with high complexity in `__del__` can cause performance issues and
 *              unpredictable behavior during garbage collection. Best practice suggests
 *              keeping these methods as straightforward as possible.
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
  exists(ClassValue containingClass |
    // The method must be the __del__ method of a class
    containingClass.declaredAttribute("__del__") = destructorMethod and
    // The method's cyclomatic complexity must exceed the threshold of 3
    destructorMethod.getScope().getMetrics().getCyclomaticComplexity() > 3
  )
select destructorMethod, "Overly complex '__del__' method."