/**
 * @name Overly complex `__del__` method
 * @description Detects Python classes with destructor methods (`__del__`) that have 
 *              high cyclomatic complexity. Destructor methods in Python are called during
 *              object cleanup, which can happen at unpredictable times or might be bypassed
 *              in certain situations. Complex destructors may lead to performance problems
 *              and unpredictable behavior during garbage collection. It's recommended to keep
 *              these special methods as simple as possible.
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
  // Ensure the method is defined as a destructor (__del__) in some class
  exists(ClassValue ownerClass | 
    ownerClass.declaredAttribute("__del__") = delMethod
  )
  and
  // Check if the cyclomatic complexity exceeds the recommended threshold
  delMethod.getScope()
      .getMetrics()
      .getCyclomaticComplexity() > 3
select delMethod, "Overly complex '__del__' method."