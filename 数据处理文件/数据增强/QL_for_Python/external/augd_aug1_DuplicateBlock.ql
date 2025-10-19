/**
 * @name Duplicate code block
 * @description Identifies duplicate code segments. This query detects when the same sequence of statements appears in multiple locations. Consider refactoring shared code into a single block to improve maintainability. Note that not all duplicates can be easily addressed; specialized checks (like duplicate function/class) provide higher-confidence subsets of these results.
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
from BasicBlock repeatedBlock
where none()
// Construct alert message with placeholder values for duplicate location
select repeatedBlock, 
  "Duplicate code: -1 lines are duplicated at <file>:-1"