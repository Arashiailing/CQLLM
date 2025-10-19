/**
 * @deprecated
 * @name Mostly duplicate module
 * @description Identifies files with substantial code duplication. Merging these files improves maintainability.
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

// Selects module pairs and warning messages without applying any filtering conditions
from Module sourceModule, Module duplicateModule, string alertMessage
where 
  none()  // No filtering logic implemented
select 
  sourceModule, 
  alertMessage, 
  duplicateModule, 
  duplicateModule.getName()