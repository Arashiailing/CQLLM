/**
 * @name Duplicate code block detection
 * @description Identifies duplicated code blocks within the codebase. Refactoring shared code into a single occurrence is recommended when feasible. Note that not all duplicates can be automatically resolved; specialized checks (like duplicate function/class detection) provide higher-confidence subsets of these findings.
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

// Define the source for code block analysis
from BasicBlock codeBlock
// Apply filtering conditions to identify duplicate blocks
where none()
// Generate alert message with duplicate code information
select codeBlock, "Duplicate code: " + "-1" + " lines are duplicated at " + "<file>" + ":" + "-1"