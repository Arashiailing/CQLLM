/**
 * @name Overly complex `__del__` method
 * @description Detects `__del__` methods with high cyclomatic complexity. These special methods may be invoked at unpredictable times or not at all, so they should be kept simple.
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

import python  // Import Python library for code analysis

from FunctionValue delMethod  // Obtain a function value representing a method
where
  // Check if the method is a __del__ method of some class
  exists(ClassValue ownerClass | 
    ownerClass.declaredAttribute("__del__") = delMethod
  )
  and
  // Verify that the method has high cyclomatic complexity
  delMethod.getScope().getMetrics().getCyclomaticComplexity() > 3
select delMethod, "Overly complex '__del__' method."  // Report the method with the issue description