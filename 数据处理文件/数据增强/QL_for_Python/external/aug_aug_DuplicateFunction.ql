/**
 * @deprecated
 * @name Duplicate function
 * @description Identical function implementation detected. Refactor by extracting shared code to common modules or base classes.
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

// Define analysis variables for duplicate function detection
from Function originalFunction, Function duplicateFunc, string message
// Placeholder condition - currently disabled for future implementation
where 
  none()
// Format output: original function, diagnostic message, duplicate function, and its name
select 
  originalFunction, 
  message, 
  duplicateFunc, 
  duplicateFunc.getName()