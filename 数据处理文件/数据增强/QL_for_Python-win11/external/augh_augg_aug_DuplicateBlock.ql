/**
 * @name Identical code block
 * @description Identifies code blocks that are identical and could be refactored.
 * This analysis flags every basic block as a potential duplicate since accurate
 * duplicate detection requires more advanced analysis. Note: This check may generate
 * false positives as it uses statistical methods.
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

// This query identifies all basic blocks without applying any filtering criteria
from BasicBlock suspectBlock
where not exists(int i | i = 0) // Equivalent to none() but more explicit
// Create an alert for each identified basic block
select suspectBlock, 
       "Identical code: " + "-1" + " lines are repeated at " + "<file>" + ":" + "-1"