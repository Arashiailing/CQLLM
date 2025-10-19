/**
 * @name Overly complex `__del__` method
 * @description Detects Python classes containing `__del__` methods with high cyclomatic complexity.
 *              The `__del__` method executes during object destruction, which occurs unpredictably
 *              and may be skipped in certain Python implementations. Complex `__del__` methods can
 *              cause performance degradation and unstable behavior during garbage collection.
 *              Best practices recommend keeping these special methods simple.
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

import python  // Import Python analysis library for code examination

from FunctionValue delMethod  // Retrieve method definition from FunctionValue
where
  exists(ClassValue ownerClass |  // Verify existence of owning class
    // Confirm method is class's __del__ implementation
    ownerClass.declaredAttribute("__del__") = delMethod and
    // Validate cyclomatic complexity exceeds threshold
    delMethod.getScope().getMetrics().getCyclomaticComplexity() > 3
  )
select delMethod, "Overly complex '__del__' method."  // Output method with warning message