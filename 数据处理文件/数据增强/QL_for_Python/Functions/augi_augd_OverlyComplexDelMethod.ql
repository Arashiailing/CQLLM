/**
 * @name Overly complex `__del__` method
 * @description Detects Python classes with complex `__del__` methods. The `__del__` special method 
 *              can be invoked unpredictably or potentially not at all, thus it should be kept simple.
 *              This query identifies `__del__` methods with cyclomatic complexity greater than 3.
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

import python  // Import Python analysis module

from FunctionValue destructorMethod  // Define the function object to analyze
where
  // Check if the function is used as a __del__ method in some class
  // and has a cyclomatic complexity greater than 3
  exists(ClassValue definingClass | 
    definingClass.declaredAttribute("__del__") = destructorMethod and
    destructorMethod.getScope().getMetrics().getCyclomaticComplexity() > 3
  )
select destructorMethod, "Overly complex '__del__' method."  // Output the results