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

// Import the Python language analysis library for static code analysis
import python

// Import the CommentedOutCode class from Lexical module to detect commented-out code segments
import Lexical.CommentedOutCode

// Define the main query to locate commented-out code blocks in Python source code
from CommentedOutCodeBlock commentedCodeBlock
// Filter out blocks that might be example code to reduce false positives
where not commentedCodeBlock.maybeExampleCode()
// Output the identified commented code blocks with an informative message
select commentedCodeBlock, "This comment appears to contain commented-out code."