/**
 * @deprecated
 * @name Duplicate function identification
 * @description Identifies functions with identical implementations across the codebase.
 *              Such duplication should be consolidated into shared modules or base classes
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

from Function sourceFunc, Function duplicateFunc, string alertMessage
where 
  sourceFunc != duplicateFunc and
  exists(sourceFunc.getBody()) and
  exists(duplicateFunc.getBody()) and
  sourceFunc.getBody() = duplicateFunc.getBody() and
  sourceFunc.getName() < duplicateFunc.getName() and
  alertMessage = "Duplicate function: " + sourceFunc.getName() + " and " + duplicateFunc.getName()
select sourceFunc, alertMessage, duplicateFunc, duplicateFunc.getName()