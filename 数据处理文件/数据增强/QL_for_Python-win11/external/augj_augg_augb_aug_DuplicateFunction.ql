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

from Function originalFunc, Function clonedFunc, string message
where 
  // Ensure functions are distinct entities
  originalFunc != clonedFunc and
  // Verify both functions have implementations
  exists(originalFunc.getBody()) and
  exists(clonedFunc.getBody()) and
  // Core check: identical function implementations
  originalFunc.getBody() = clonedFunc.getBody() and
  // Prevent duplicate reporting by enforcing lexical ordering
  originalFunc.getName() < clonedFunc.getName() and
  // Construct alert message
  message = "Duplicate function: " + originalFunc.getName() + " and " + clonedFunc.getName()
select originalFunc, message, clonedFunc, clonedFunc.getName()