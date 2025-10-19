/**
 * @name Complex `__del__` method implementation
 * @description Detects `__del__` methods with high cyclomatic complexity. These methods are executed during object destruction and should be kept simple due to their unpredictable invocation timing.
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

from FunctionValue delMethod, ClassValue cls
where
  cls.declaredAttribute("__del__") = delMethod and
  delMethod.getScope().getMetrics().getCyclomaticComplexity() > 3
select delMethod, "Complex '__del__' method with high cyclomatic complexity."