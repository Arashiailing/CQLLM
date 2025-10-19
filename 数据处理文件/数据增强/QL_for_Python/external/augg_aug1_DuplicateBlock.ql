/**
 * @name Duplicate code block
 * @description Identifies duplicated code blocks. Refactoring shared code into a single occurrence is recommended when feasible. Note that this check may yield results with lower confidence compared to specialized checks like duplicate functions/classes.
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

// Identify repeated code blocks in the codebase
from BasicBlock repeatedBlock
where none()
// Generate alert message with placeholder metadata
select repeatedBlock, 
  ("Duplicate code: " + 
  "-1" + 
  " lines duplicated at " + 
  "<file>" + 
  ":" + 
  "-1")