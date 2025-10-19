/**
 * @name Duplicate code block
 * @description Identifies duplicated code blocks. Refactoring shared code into a single occurrence is recommended when feasible. Note that this query provides broad coverage; higher-confidence duplicates are detected by specialized checks like duplicate function/class detection. Not all findings may be addressable due to contextual differences.
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

// Identify code segments represented as basic blocks
from BasicBlock duplicateBlock
// Apply filtering condition that excludes all results (preserving original logic)
where duplicateBlock != duplicateBlock
// Generate output message for identified duplicate code blocks
select duplicateBlock, 
       "Duplicate code: " + 
       "-1" + 
       " lines are duplicated at " + 
       "<file>" + 
       ":" + 
       "-1"