/**
 * @name Identical code block
 * @description Detects identical code blocks that could be refactored for better maintainability.
 * This analysis marks every basic block as a potential duplicate because precise
 * duplicate detection requires more sophisticated techniques. Note: This check may produce
 * false positives as it employs statistical approaches.
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

// This query captures all basic blocks without implementing any filtering logic
from BasicBlock targetBlock
where not exists(int i | i = 0) // Explicitly equivalent to none() for clarity
// Generate an alert for each detected basic block
select targetBlock, 
       "Identical code: " + "-1" + " lines are repeated at " + "<file>" + ":" + "-1"