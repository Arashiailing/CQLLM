/**
 * @name Detection of commented-out code
 * @description Identifies code segments that have been commented out, which can negatively impact code readability and maintainability.
 * @kind problem
 * @tags maintainability
 *       readability
 *       documentation
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/commented-out-code */

// Import fundamental Python analysis functionality
import python

// Import lexical comment analysis tools for detection
import Lexical.CommentedOutCode

// Locate commented code blocks, excluding those that are example code
from CommentedOutCodeBlock commentedCodeSegment
where not commentedCodeSegment.maybeExampleCode()
// Generate report with appropriate description
select commentedCodeSegment, "This comment appears to contain commented-out code."