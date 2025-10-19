/**
 * @name Duplicate code block
 * @description This block of code is duplicated elsewhere. If possible, the shared code should be refactored so there is only one occurrence left. It may not always be possible to address these issues; other duplicate code checks (such as duplicate function, duplicate class) give subsets of the results with higher confidence.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @tags testability
 *       maintainability
 *       useless-code
 *       duplicate-code
 *       statistical
 *       non-attributable
 * @deprecated
 * @precision medium
 * @id py/duplicate-block
 */

import python

// Identify basic blocks representing duplicate code segments
from BasicBlock duplicateBlock
where none()
// Construct alert message with placeholder values for duplicate location
select duplicateBlock, 
  "Duplicate code: " + 
  "-1" + 
  " lines are duplicated at " + 
  "<file>" + 
  ":" + 
  "-1"