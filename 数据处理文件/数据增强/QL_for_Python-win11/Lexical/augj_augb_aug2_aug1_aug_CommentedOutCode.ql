/**
 * @name Commented-out code
 * @description Identifies code segments that developers have commented out, which can reduce code readability and hinder long-term maintenance.
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

// Import the CommentedOutCode class from Lexical module for detecting commented code
import Lexical.CommentedOutCode

// Define the main query to detect commented-out code sections
from CommentedOutCodeBlock inactiveCodeSegment
// Filter out blocks that might be example code or documentation
where not inactiveCodeSegment.maybeExampleCode()
// Report the identified commented code blocks with a warning message
select inactiveCodeSegment, "This comment appears to contain commented-out code."