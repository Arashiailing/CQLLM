/**
 * @name Duplicate code block
 * @description Identifies duplicated code segments that could potentially be refactored. 
 *              While not always actionable, these duplicates may indicate opportunities 
 *              for code consolidation. More specific duplicate checks (functions/classes) 
 *              provide higher-confidence subsets of these findings.
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
from BasicBlock dupBlock
where none()
// Construct alert message with placeholder values for duplicate location
select dupBlock, 
  ("Duplicate code: " + 
  "-1" + 
  " lines are duplicated at " + 
  "<file>" + 
  ":" + 
  "-1")