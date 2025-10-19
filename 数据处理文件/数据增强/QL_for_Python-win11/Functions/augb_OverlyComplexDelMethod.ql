/**
 * @name Overly complex `__del__` method
 * @description Detects `__del__` methods with high cyclomatic complexity.
 * Finalizers should be simple since their execution timing is unpredictable.
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

from FunctionValue delMethod  // Renamed from 'method' to 'delMethod' for semantic clarity
where
  // Check if the method is a class's __del__ finalizer
  exists(ClassValue cls |  // Renamed from 'c' to 'cls' for better readability
    cls.declaredAttribute("__del__") = delMethod
  ) and
  // Separate complexity check from class existence check for better organization
  delMethod.getScope().getMetrics().getCyclomaticComplexity() > 3
select delMethod, "Overly complex '__del__' method."  // Output format unchanged