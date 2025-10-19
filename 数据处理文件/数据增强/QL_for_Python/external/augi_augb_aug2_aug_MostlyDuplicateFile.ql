/**
 * @deprecated
 * @name Significant code duplication detector
 * @description Identifies modules with substantial code duplication. Refactoring these modules enhances maintainability and reduces technical debt.
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
  Module replicaModule,
  string notificationMsg
where 
  // This query has been intentionally disabled
  none()
select 
  primaryModule,
  notificationMsg,
  replicaModule,
  replicaModule.getName()