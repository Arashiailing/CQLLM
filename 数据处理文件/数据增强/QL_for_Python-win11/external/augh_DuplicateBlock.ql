/**
 * @name Duplicate code block
 * @description Identifies duplicated code blocks across the codebase. 
 * Refactoring shared code into a single implementation is recommended 
 * when feasible. Note that higher-confidence duplicates (functions/classes) 
 * are detected by other specialized checks.
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

// Retrieve all basic blocks from the codebase
// Note: Original logic uses `none()` which matches all blocks
from BasicBlock codeBlock
where none()
// Generate alert message with placeholder values
select codeBlock, 
       "Duplicate code: " + "-1" + " lines are duplicated at " + "<file>" + ":" + "-1"