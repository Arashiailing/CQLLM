/**
 * @name Overly complex `__del__` method
 * @description Detects `__del__` methods with high cyclomatic complexity. In Python, the `__del__` special method 
 *              is called during object destruction, a process that happens at unpredictable times or may not 
 *              occur at all. Implementing complex logic in these methods can lead to performance degradation and
 *              erratic behavior during garbage collection cycles.
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
  // Find classes that declare a __del__ method
  exists(ClassValue parentClass | 
    parentClass.declaredAttribute("__del__") = destructorMethod
  )
  // Check if the __del__ method has excessive complexity
  and 
  destructorMethod.getScope().getMetrics().getCyclomaticComplexity() > 3
select destructorMethod, "Overly complex '__del__' method."