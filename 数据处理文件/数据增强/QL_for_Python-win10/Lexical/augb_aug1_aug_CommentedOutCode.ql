/**
 * @name Commented-out code
 * @description Identifies code segments that have been commented out during development. 
 *              Such practices can significantly reduce code clarity and create maintenance 
 *              challenges over time, as dead code may accumulate and confuse developers.
 * @kind problem
 * @tags maintainability
 *       readability
 *       documentation
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/commented-out-code */

// Import the Python language analysis library for code parsing and analysis
import python

// Import the CommentedOutCode class from Lexical module to identify commented code segments
import Lexical.CommentedOutCode

// Define the main query to detect problematic commented code blocks
from CommentedOutCodeBlock commentedBlock
// Apply filtering to exclude legitimate code examples or documentation comments
where not commentedBlock.maybeExampleCode()
// Present the identified commented code blocks with an appropriate warning message
select commentedBlock, "This comment appears to contain commented-out code."