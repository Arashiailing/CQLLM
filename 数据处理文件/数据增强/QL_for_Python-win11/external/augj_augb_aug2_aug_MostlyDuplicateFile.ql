/**
 * @deprecated
 * @name Substantial code duplication identifier
 * @description Detects modules containing significant amounts of duplicated code. Refactoring these modules improves code maintainability and reduces technical debt. This query is intentionally disabled.
 * @kind problem
 * @tags testability
 *       maintainability
 *       useless-code
 *       duplicate-code
 *       statistical
 *       non-attributable
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/mostly-duplicate-file
 */

import python

from 
  Module originalModule,
  Module clonedModule,
  string warningMessage
where 
  // Query intentionally disabled
  none()
select 
  originalModule,
  warningMessage,
  clonedModule,
  clonedModule.getName()