/**
 * @deprecated
 * @name Significant code duplication detector
 * @description Detects modules exhibiting substantial code duplication. Consolidation enhances maintainability and reduces technical debt.
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
  Module clonedModule,
  string diagnosticMessage
where 
  none()
select 
  primaryModule,
  diagnosticMessage,
  clonedModule,
  clonedModule.getName()