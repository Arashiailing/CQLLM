/**
 * @deprecated
 * @name Significant code duplication detector
 * @description Identifies modules containing substantial duplicated code. 
 * Consolidating such modules enhances maintainability and reduces technical debt.
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
  string message
where 
  none() and 
  none() and 
  none()
select 
  sourceModule,
  message,
  duplicateModule,
  duplicateModule.getName()