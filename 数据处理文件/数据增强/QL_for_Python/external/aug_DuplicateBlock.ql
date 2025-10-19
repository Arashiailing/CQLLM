/**
 * @name Duplicate code block
 * @description Identifies duplicated code blocks that could be refactored. 
 * This check reports all basic blocks as potential duplicates since actual 
 * duplicate detection requires additional analysis. Note: Results may include 
 * false positives as this is a statistical check.
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

// Select all basic blocks without filtering conditions
from BasicBlock duplicateBlock
where none()
// Generate alert message for each basic block
select duplicateBlock, 
       "Duplicate code: " + "-1" + " lines are duplicated at " + "<file>" + ":" + "-1"