/**
 * @deprecated
 * @name Duplicate function
 * @description Detects functions with identical implementations. Consider refactoring by extracting shared code into common modules or base classes.
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

// Analysis variables for duplicate function detection
from Function originalFn, Function duplicateFn, string diagnosticMessage
// Placeholder condition - disabled pending future implementation
where 
  none()
// Output format: original function, diagnostic message, duplicate function, and its name
select 
  originalFn, 
  diagnosticMessage, 
  duplicateFn, 
  duplicateFn.getName()