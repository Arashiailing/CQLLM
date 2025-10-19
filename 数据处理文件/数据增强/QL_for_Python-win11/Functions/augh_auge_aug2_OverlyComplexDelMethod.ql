/**
 * @name Overly complex `__del__` method
 * @description Identifies `__del__` methods with high cyclomatic complexity.
 *              The `__del__` method is a destructor that gets called when an object
 *              is about to be destroyed. Since the timing of destruction is not
 *              predictable in Python, complex destructors can lead to performance
 *              issues and make debugging difficult. This query flags destructors
 *              with cyclomatic complexity exceeding 3, recommending they be simplified.
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
  exists(ClassValue containingClass |
    // Verify the method is defined as __del__ within a class
    containingClass.declaredAttribute("__del__") = destructorMethod and
    // Check if the method's cyclomatic complexity exceeds the safe threshold
    destructorMethod.getScope().getMetrics().getCyclomaticComplexity() > 3
  )
select destructorMethod, "Overly complex '__del__' method."