/**
 * @name Overly complex `__del__` method
 * @description Identifies Python classes with `__del__` methods exhibiting high cyclomatic complexity.
 *              The `__del__` method executes during object destruction, which occurs unpredictably
 *              and may be skipped in certain scenarios. Excessively complex destructors can cause
 *              performance issues and erratic garbage collection behavior. Best practice dictates
 *              keeping these special methods minimal and straightforward.
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
  exists(ClassValue owningClass |
    // Verify the method is the class's __del__ destructor
    owningClass.declaredAttribute("__del__") = destructorMethod and
    // Check if cyclomatic complexity exceeds recommended threshold (3)
    destructorMethod.getScope().getMetrics().getCyclomaticComplexity() > 3
  )
select destructorMethod, "Overly complex '__del__' method."