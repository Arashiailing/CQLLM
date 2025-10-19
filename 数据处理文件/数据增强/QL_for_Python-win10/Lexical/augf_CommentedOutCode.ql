/**
 * @name Commented-out code
 * @description Identifies code blocks that have been commented out, which can reduce code readability and maintainability.
 * @kind problem
 * @tags maintainability
 *       readability
 *       documentation
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/commented-out-code
 */

// Import the Python language library for analysis
import python

// Import the CommentedOutCode class from the Lexical module
import Lexical.CommentedOutCode

// Retrieve all commented code blocks
from CommentedOutCodeBlock commentedBlock
// Exclude blocks that might be example code
where not commentedBlock.maybeExampleCode()
// Output the commented code blocks with a descriptive message
select commentedBlock, "This comment appears to contain commented-out code."