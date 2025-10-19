/**
 * @name Commented-out code
 * @description Identifies code segments that have been commented out, which can negatively impact code readability and maintenance efforts.
 * @kind problem
 * @tags maintainability
 *       readability
 *       documentation
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/commented-out-code */

// Import fundamental Python language analysis functionality
import python

// Import lexical analysis tools specifically designed for detecting commented code
import Lexical.CommentedOutCode

// Query to find commented code blocks, excluding those that are likely example code
from CommentedOutCodeBlock commentedCodeBlock
where not commentedCodeBlock.maybeExampleCode()
// Output the identified commented code blocks with an appropriate message
select commentedCodeBlock, "This comment appears to contain commented-out code."