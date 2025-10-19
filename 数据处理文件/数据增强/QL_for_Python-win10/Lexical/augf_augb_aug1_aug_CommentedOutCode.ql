/**
 * @name Commented-out code
 * @description Detects code segments that have been commented out during development. 
 *              This practice can lead to decreased code clarity and maintenance difficulties,
 *              as inactive code may accumulate and cause confusion among developers.
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

// Main query to identify problematic commented code blocks
from CommentedOutCodeBlock problematicComment
// Filter out legitimate code examples or documentation comments
where not problematicComment.maybeExampleCode()
// Display the identified commented code blocks with a warning message
select problematicComment, "This comment appears to contain commented-out code."