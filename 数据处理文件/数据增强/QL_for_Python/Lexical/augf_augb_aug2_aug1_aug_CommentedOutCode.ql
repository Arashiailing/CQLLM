/**
 * @name Commented-out code
 * @description Detects inactive code segments preserved in comments, which may compromise code maintainability and readability over time.
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

// Identify commented code blocks excluding documentation/examples
from CommentedOutCodeBlock inactiveCodeSegment
where not inactiveCodeSegment.maybeExampleCode()
// Flag problematic commented code segments with maintenance warning
select inactiveCodeSegment, "This comment appears to contain commented-out code."