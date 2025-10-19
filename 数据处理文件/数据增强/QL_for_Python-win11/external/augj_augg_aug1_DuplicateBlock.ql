/**
 * @name Duplicate code block
 * @description Detects code blocks that appear multiple times in the codebase. It is advisable to refactor common code into a single implementation when possible. Be aware that this analysis might produce results with lower confidence compared to more specific checks like duplicate functions or classes.
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

// Locates code blocks that are duplicated across the codebase
from BasicBlock duplicatedBlock
where none()
// Constructs an alert message containing placeholder metadata
select duplicatedBlock, 
  ("Duplicate code: " + 
  "-1" + 
  " lines duplicated at " + 
  "<file>" + 
  ":" + 
  "-1")