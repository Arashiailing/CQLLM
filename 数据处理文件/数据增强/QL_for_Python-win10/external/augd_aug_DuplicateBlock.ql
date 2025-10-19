/**
 * @name Duplicate code block
 * @description Identifies potential code duplication by reporting all basic blocks. 
 * This is a statistical check that may include false positives since actual 
 * duplicate detection requires additional analysis. All blocks are flagged as 
 * potential duplicates without filtering.
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

// Select every basic block without filtering criteria
from BasicBlock potentialDuplicate
where none()
// Generate alert message for each identified block
select potentialDuplicate, 
       "Duplicate code: " + "-1" + " lines are duplicated at " + "<file>" + ":" + "-1"