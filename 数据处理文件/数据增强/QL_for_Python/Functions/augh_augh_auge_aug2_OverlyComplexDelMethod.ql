/**
 * @name Complex `__del__` destructor method
 * @description Detects Python destructor methods (`__del__`) that have high cyclomatic complexity.
 *              Destructors are special methods called when an object is about to be destroyed.
 *              Due to the unpredictable timing of object destruction in Python, overly complex
 *              destructors can cause performance problems and complicate debugging. This query
 *              identifies destructors with cyclomatic complexity greater than 3, suggesting
 *              refactoring to simplify their logic.
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
    // Confirm that the method is the __del__ destructor of a class
    ownerClass.declaredAttribute("__del__") = delMethod and
    // Evaluate if the method's cyclomatic complexity exceeds the recommended threshold
    delMethod.getScope().getMetrics().getCyclomaticComplexity() > 3
  )
select delMethod, "Overly complex '__del__' method."