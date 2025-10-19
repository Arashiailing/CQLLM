/**
 * @name Commented-out code
 * @description Commented-out code makes the remaining code more difficult to read.
 * @kind problem
 * @tags maintainability
 *       readability
 *       documentation
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/commented-out-code
 */

// Import the Python language library
import python

// Import the CommentedOutCode class from the Lexical module
import Lexical.CommentedOutCode

// Define the source of commented-out code blocks
from CommentedOutCodeBlock commentedBlock

// Filter out blocks that might be example code
where not commentedBlock.maybeExampleCode()

// Select the remaining blocks with an appropriate message
select commentedBlock, "This comment appears to contain commented-out code."