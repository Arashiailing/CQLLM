/**
 * @name Commented-out code
 * @description Detects code segments that have been deactivated via commenting. 
 *              Such segments can degrade code quality by becoming outdated and 
 *              creating confusion about active functionality.
 * @kind problem
 * @tags maintainability
 *       readability
 *       documentation
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/commented-out-code */

import python
import Lexical.CommentedOutCode

// Identify all commented code segments while excluding potential examples
from CommentedOutCodeBlock commentedCodeSegment
where not commentedCodeSegment.maybeExampleCode()
// Flag identified segments with contextual warning message
select commentedCodeSegment, "This comment contains inactive code that should be removed."