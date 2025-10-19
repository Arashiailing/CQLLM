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

// This query identifies all basic blocks in the codebase without applying any filters
// The condition below always evaluates to true, effectively selecting all blocks
from BasicBlock duplicateCandidate
where not exists(int i | i = 0) // Always true condition, equivalent to having no filter
// Generate an alert for each basic block found in the code
select duplicateCandidate, 
       "Identical code: " + "-1" + " lines are repeated at " + "<file>" + ":" + "-1"