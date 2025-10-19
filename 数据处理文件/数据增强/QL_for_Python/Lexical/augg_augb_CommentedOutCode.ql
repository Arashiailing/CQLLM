/**
 * @name Commented-out code
 * @description Detects code fragments that have been deactivated through commenting,
 *              which may negatively impact code clarity and maintenance efforts.
 * @kind problem
 * @tags maintainability
 *       readability
 *       documentation
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/commented-out-code
 */

// Import required libraries for code analysis
import python
import Lexical.CommentedOutCode

// Main query to identify inactive code sections that have been commented out
from CommentedOutCodeBlock inactiveCodeBlock
// Apply filter to exclude code blocks that appear to be examples or documentation
where not inactiveCodeBlock.maybeExampleCode()
// Return the identified commented code blocks with a descriptive message
select inactiveCodeBlock, "This comment appears to contain commented-out code."