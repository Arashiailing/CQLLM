/**
 * @deprecated
 * @name Duplicate function identification
 * @description Detects functions with identical implementations across the codebase.
 *              Such duplication should be consolidated into shared modules or base classes
 *              to enhance code reusability and maintainability.
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

from Function originalFunc, Function cloneFunc, string alertMessage
where none()
select originalFunc, alertMessage, cloneFunc, cloneFunc.getName()