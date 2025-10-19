/**
 * @name Identical code block detection
 * @description Identifies blocks of code that appear multiple times in the codebase. Refactoring shared code into a single location is recommended when feasible. Note that not all duplicates can be automatically resolved; specialized checks for duplicate functions or classes provide more targeted results with higher confidence.
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

// Query for identifying duplicate code blocks
from BasicBlock duplicateBlock
where none()
// Generate alert message for each detected duplicate block
select duplicateBlock, "Duplicate code: " + "-1" + " lines are duplicated at " + "<file>" + ":" + "-1"