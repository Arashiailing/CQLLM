/**
 * @name Commented-out code
 * @description Detects code blocks that have been commented out in the source code.
 *              Such inactive code can decrease readability and make maintenance more difficult.
 * @kind problem
 * @tags maintainability
 *       readability
 *       documentation
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/commented-out-code
 */

// Import required libraries and modules for Python code analysis
import python
import Lexical.CommentedOutCode

// Query to identify commented-out code blocks in the source code
from CommentedOutCodeBlock inactiveCodeBlock
// Filter out code blocks that might be examples or documentation
where not inactiveCodeBlock.maybeExampleCode()
// Return the identified commented-out code block with a descriptive message
select inactiveCodeBlock, "This comment appears to contain commented-out code."