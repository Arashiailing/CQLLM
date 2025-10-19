/**
 * @name Detection of commented-out code
 * @description Identifies code segments that have been deactivated via commenting.
 *              Such code can impair readability and maintainability, as it often
 *              becomes outdated and may create confusion about the intended
 *              functionality of the codebase.
 * @kind problem
 * @tags maintainability
 *       readability
 *       documentation
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/commented-out-code */

// Import required modules for Python code analysis
import python
import Lexical.CommentedOutCode

// Locate commented-out code blocks while excluding likely examples
from CommentedOutCodeBlock commentedBlock
where not commentedBlock.maybeExampleCode()
// Report identified blocks with descriptive message
select commentedBlock, "This comment appears to contain commented-out code."