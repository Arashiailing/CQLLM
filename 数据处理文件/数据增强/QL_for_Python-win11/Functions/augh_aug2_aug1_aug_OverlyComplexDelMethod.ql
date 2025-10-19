/**
 * @name Overly complex `__del__` method
 * @description This rule identifies Python classes containing `__del__` methods with high cyclomatic complexity.
 *              The `__del__` method in Python is invoked during object destruction, a process that
 *              can occur unpredictably or may be skipped entirely in certain scenarios.
 *              Methods with high complexity in `__del__` can cause performance issues and
 *              erratic behavior during garbage collection cycles. Best practices suggest
 *              maintaining minimal complexity in these special methods.
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
  exists(ClassValue ownerClass |
    // Verify the method is the __del__ method of a class
    ownerClass.declaredAttribute("__del__") = destructorMethod
  ) and
  // Check if the method's cyclomatic complexity exceeds the threshold of 3
  destructorMethod.getScope().getMetrics().getCyclomaticComplexity() > 3
select destructorMethod, "Overly complex '__del__' method."