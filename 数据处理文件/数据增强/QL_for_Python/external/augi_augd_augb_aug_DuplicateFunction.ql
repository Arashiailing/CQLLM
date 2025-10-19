/**
 * @name Duplicate Function Detection
 * @description Identifies functions that have identical implementations. 
 *              Duplicate code should be refactored into shared utilities or base classes 
 *              to improve code reusability and maintainability.
 * @kind problem
 * @tags testability
 *       useless-code
 *       maintainability
 *       duplicate-code
 *       statistical
 *       non-attributable
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/duplicate-function
 */

import python

from Function duplicateFunction, Function originalFunction, string alertMessage
where
  duplicateFunction != originalFunction and
  duplicateFunction.getBody() = originalFunction.getBody() and
  (
    duplicateFunction.getLocation().getFile().getAbsolutePath() < originalFunction.getLocation().getFile().getAbsolutePath()
    or
    (
      duplicateFunction.getLocation().getFile().getAbsolutePath() = originalFunction.getLocation().getFile().getAbsolutePath() and
      duplicateFunction.getName() < originalFunction.getName()
    )
  ) and
  alertMessage = "This function is a duplicate of " + originalFunction.getName() + "."
select duplicateFunction, alertMessage, originalFunction, originalFunction.getName()