/**
 * @deprecated
 * @name Significant code duplication detector
 * @description Identifies modules with substantial code duplication to improve maintainability and reduce technical debt.
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
  Module replicatedModule,
  string notificationMessage
where 
  // Query intentionally deactivated
  none()
select 
  originalModule,
  notificationMessage,
  replicatedModule,
  replicatedModule.getName()