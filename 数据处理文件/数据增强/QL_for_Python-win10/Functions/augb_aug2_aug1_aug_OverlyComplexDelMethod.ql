/**
 * @name Overly complex `__del__` method
 * @description Detects Python classes containing `__del__` methods with excessive cyclomatic complexity.
 *              The `__del__` method in Python is called during object destruction, which can happen
 *              unpredictably or might be bypassed in certain situations. Complex `__del__` methods
 *              may lead to performance degradation and unpredictable behavior during garbage collection.
 *              It's recommended to keep these special methods as simple as possible.
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
  exists(ClassValue ownerClass |
    // Confirm the method is the __del__ destructor of the class
    ownerClass.declaredAttribute("__del__") = delMethod and
    // Evaluate if the method's cyclomatic complexity exceeds the threshold of 3
    delMethod.getScope().getMetrics().getCyclomaticComplexity() > 3
  )
select delMethod, "Overly complex '__del__' method."