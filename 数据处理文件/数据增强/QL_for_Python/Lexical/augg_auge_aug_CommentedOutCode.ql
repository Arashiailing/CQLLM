/**
 * @name Commented-out code
 * @description Identifies code segments deactivated through commenting. Such code 
 *              can hinder readability and maintainability, as it often becomes 
 *              outdated and may confuse developers about the intended functionality.
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

// Locate all commented-out code blocks in the project
from CommentedOutCodeBlock inactiveCodeBlock
// Filter out blocks likely representing example code to reduce false positives
where not inactiveCodeBlock.maybeExampleCode()
// Report the identified inactive code blocks with an informative message
select inactiveCodeBlock, "This comment appears to contain commented-out code."