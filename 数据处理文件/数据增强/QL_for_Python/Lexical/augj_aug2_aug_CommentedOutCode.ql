/**
 * @name Commented-out code
 * @description Detects segments of code that have been commented out, potentially impacting code clarity and maintenance efforts.
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

// Define the main query to identify commented-out code segments in Python source files
from CommentedOutCodeBlock commentedOutCodeSegment
// Exclude code blocks that are likely to be example code to minimize false positive results
where not commentedOutCodeSegment.maybeExampleCode()
// Report the identified commented code segments with a descriptive message
select commentedOutCodeSegment, "This comment appears to contain commented-out code."