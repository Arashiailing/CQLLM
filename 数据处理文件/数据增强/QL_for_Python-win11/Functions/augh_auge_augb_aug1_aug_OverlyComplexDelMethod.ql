/**
 * @name Overly complex `__del__` method
 * @description Identifies Python classes with destructors (`__del__` methods) that 
 *              have high cyclomatic complexity. Python destructors are invoked during
 *              object cleanup, which occurs at unpredictable times or may be skipped
 *              under certain conditions. Complex destructors can cause performance issues
 *              and unpredictable behavior during garbage collection. Best practice is to
 *              keep these special methods minimal and straightforward.
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

from FunctionValue destructorMethod,
      ClassValue containingClass
where
  // Verify that the method is the __del__ destructor of a class
  containingClass.declaredAttribute("__del__") = destructorMethod
  and
  // Calculate and check the cyclomatic complexity of the destructor
  exists(int complexity |
    complexity = destructorMethod.getScope().getMetrics().getCyclomaticComplexity() and
    complexity > 3
  )
select destructorMethod, "Overly complex '__del__' method."