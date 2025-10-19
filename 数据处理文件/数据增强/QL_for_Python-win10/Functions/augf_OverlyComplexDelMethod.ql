/**
 * @name Overly complex `__del__` method
 * @description The `__del__` method is called at arbitrary times during garbage collection,
 *              and may never be called at all. Complex logic in `__del__` can lead to
 *              unpredictable behavior and resource leaks. This query identifies `__del__`
 *              methods with cyclomatic complexity exceeding the recommended threshold of 3.
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
  exists(ClassValue targetClass |
    targetClass.declaredAttribute("__del__") = delMethod and
    delMethod.getScope().getMetrics().getCyclomaticComplexity() > 3
  )
select delMethod, "Overly complex '__del__' method."