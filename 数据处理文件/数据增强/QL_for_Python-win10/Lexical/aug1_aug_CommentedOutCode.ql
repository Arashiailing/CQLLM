/**
 * @name Commented-out code
 * @description Detects code segments that have been commented out by developers, which can negatively impact code readability and long-term maintainability.
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

// Define the main query logic to find problematic commented code blocks
from CommentedOutCodeBlock commentedCodeSegment
// Filter condition: exclude blocks that might be example code or documentation
where not commentedCodeSegment.maybeExampleCode()
// Output the identified commented code segments with an appropriate warning message
select commentedCodeSegment, "This comment appears to contain commented-out code."