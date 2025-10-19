/**
 * @name Inactive commented code detection
 * @description Detects code segments that have been deactivated through commenting,
 * which can negatively impact code clarity and maintenance by preserving outdated
 * or non-executable code within the source files.
 * @kind problem
 * @tags maintainability
 *       readability
 *       documentation
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/commented-out-code
 */

// Import Python language support for source code analysis
import python

// Import lexical analysis utilities to identify commented code sections
import Lexical.CommentedOutCode

// Define the main query to find commented code blocks
from CommentedOutCodeBlock inactiveCode
// Apply filtering condition to exclude legitimate documentation or example code
where not inactiveCode.maybeExampleCode()
// Generate alert for each identified commented code block
select inactiveCode, "This comment contains code that has been commented out and is no longer active."