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
 * @id py/commented-out-code */

// Import Python language support for code analysis
import python

// Import lexical analysis capabilities for detecting commented code
import Lexical.CommentedOutCode

// Main query to find commented-out code blocks
from CommentedOutCodeBlock commentedBlock
// Filter out blocks that are likely examples or documentation
where not commentedBlock.maybeExampleCode()
// Report each commented code block with an alert message
select commentedBlock, "This comment appears to contain commented-out code, which may reduce code maintainability."