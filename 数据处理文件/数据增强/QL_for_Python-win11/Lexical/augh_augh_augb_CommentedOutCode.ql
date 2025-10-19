/**
 * @name Commented-out code
 * @description Identifies code segments that have been deactivated through commenting.
 *              Such dormant code fragments can obscure codebase clarity and complicate future maintenance efforts.
 * @kind problem
 * @tags maintainability
 *       readability
 *       documentation
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/commented-out-code
 */

// Import necessary modules for Python source code analysis
import python
import Lexical.CommentedOutCode

// Query to locate code blocks that have been commented out in the source
from CommentedOutCodeBlock commentedCodeBlock
// Exclude code blocks that could be documentation or example code
where not commentedCodeBlock.maybeExampleCode()
// Report the discovered commented-out code block with an informative message
select commentedCodeBlock, "This comment appears to contain commented-out code."