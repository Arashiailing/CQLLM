/**
 * @name Duplicate code block detection
 * @description Identifies blocks of code that are duplicated in the codebase. 
 *              Refactoring shared code into a single location improves maintainability 
 *              and reduces the risk of inconsistencies. Note that this is a general 
 *              detection; more specific duplicate checks (like duplicate functions or classes) 
 *              provide higher-confidence results.
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

// Identify basic blocks that may contain duplicated code
from BasicBlock duplicateBlock
where none()
// Generate alert message with details about the duplicated code block
select duplicateBlock, "Duplicate code: " + "-1" + " lines are duplicated at " + "<file>" + ":" + "-1"