/**
 * @name Commented-out code
 * @description Identifies code segments that have been commented out, which can reduce code readability and maintainability.
 * @kind problem
 * @tags maintainability
 *       readability
 *       documentation
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/commented-out-code */

// Import the Python language analysis library
import python

// Import the CommentedOutCode class from Lexical module for code analysis
import Lexical.CommentedOutCode

// Define a query that identifies commented-out code blocks
from CommentedOutCodeBlock commentBlock
// Apply filter to exclude example code blocks
where not commentBlock.maybeExampleCode()
// Select the identified comment blocks with descriptive message
select commentBlock, "This comment appears to contain commented-out code."