/**
 * @name Commented-out code
 * @description Identifies code segments that have been commented out by developers, 
 *              which can reduce code readability and long-term maintainability.
 * @kind problem
 * @tags maintainability
 *       readability
 *       documentation
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/commented-out-code */

// Import Python language analysis library for code parsing and analysis
import python

// Import CommentedOutCode class from Lexical module to detect commented code segments
import Lexical.CommentedOutCode

// Define main query logic to locate problematic commented code blocks
from CommentedOutCodeBlock commentedBlock
// Filter condition: exclude blocks potentially containing example code or documentation
where not commentedBlock.maybeExampleCode()
// Output identified commented code blocks with descriptive warning message
select commentedBlock, "This comment appears to contain commented-out code."