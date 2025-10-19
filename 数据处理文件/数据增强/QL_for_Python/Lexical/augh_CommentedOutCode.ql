/**
 * @name Commented-out code
 * @description Identifies code that has been commented out, which can reduce code readability
 * and maintainability by leaving obsolete or non-functional code in the source.
 * @kind problem
 * @tags maintainability
 *       readability
 *       documentation
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/commented-out-code
 */

// Import Python language support for analysis
import python

// Import lexical analysis capabilities to detect commented code
import Lexical.CommentedOutCode

// Select all commented code blocks from the source code
from CommentedOutCodeBlock commentedCode
// Filter to exclude blocks that represent example code or documentation
where not commentedCode.maybeExampleCode()
// Report the commented code block with an appropriate message
select commentedCode, "This comment appears to contain commented-out code."