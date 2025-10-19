/**
 * @deprecated
 * @name Significant code duplication detector
 * @description Identifies modules with substantial code duplication. Consolidation improves maintainability and reduces technical debt.
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
  none()
select 
  sourceModule,
  alertMessage,
  duplicateModule,
  duplicateModule.getName()