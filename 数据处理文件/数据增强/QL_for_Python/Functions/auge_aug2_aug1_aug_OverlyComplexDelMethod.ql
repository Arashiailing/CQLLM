/**
 * @name Overly complex `__del__` method
 * @description Detects Python classes containing `__del__` methods with high cyclomatic complexity.
 *              The `__del__` method in Python is called during object destruction, a process
 *              that can happen unpredictably or might not occur at all in certain situations.
 *              Complex logic within `__del__` methods can lead to performance degradation
 *              and unpredictable behavior during garbage collection. It's recommended
 *              to keep these special methods as simple as possible.
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
    // Verify the method is the class's __del__ method
    ownerClass.declaredAttribute("__del__") = destructorMethod and
    // Check if the method's cyclomatic complexity exceeds the threshold
    destructorMethod.getScope().getMetrics().getCyclomaticComplexity() > 3
  )
select destructorMethod, "Overly complex '__del__' method."