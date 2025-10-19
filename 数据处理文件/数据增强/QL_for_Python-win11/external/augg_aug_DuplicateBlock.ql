/**
 * @name Identical code block
 * @description Detects code blocks that are identical and could potentially be refactored.
 * This analysis flags every basic block as a possible duplicate since true
 * duplicate identification needs more sophisticated analysis. Note: This check may produce
 * false positives as it relies on statistical methods.
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

// This query selects all basic blocks without any filtering conditions
from BasicBlock repeatedBlock
where none()
// Generate an alert message for each basic block found
select repeatedBlock, 
       "Identical code: " + "-1" + " lines are repeated at " + "<file>" + ":" + "-1"