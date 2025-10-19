/**
 * @deprecated
 * @name Significant code duplication identifier
 * @description Detects Python modules containing substantial code duplication. Refactoring duplicated code enhances maintainability and reduces technical debt.
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
  Module primaryModule,
  Module replicatedModule,
  string notificationMsg
where 
  none()
select 
  primaryModule,
  notificationMsg,
  replicatedModule,
  replicatedModule.getName()