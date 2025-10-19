/**
 * @deprecated
 * @name Mostly duplicate module
 * @description Identifies files with significant code duplication. Merging duplicate files improves maintainability and reduces technical debt.
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
  Module sourceFile, 
  Module duplicateFile, 
  string alertMessage
where 
  none()
select 
  sourceFile, 
  alertMessage, 
  duplicateFile, 
  duplicateFile.getName()