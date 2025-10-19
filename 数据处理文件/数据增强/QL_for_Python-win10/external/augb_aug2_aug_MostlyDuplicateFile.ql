/**
 * @deprecated
 * @name Substantial code duplication identifier
 * @description Detects modules that contain significant amounts of duplicated code. Refactoring these modules improves code maintainability and decreases technical debt.
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
  Module sourceModule,
  Module duplicateModule,
  string alertMessage
where 
  // This query is intentionally disabled
  none()
select 
  sourceModule,
  alertMessage,
  duplicateModule,
  duplicateModule.getName()