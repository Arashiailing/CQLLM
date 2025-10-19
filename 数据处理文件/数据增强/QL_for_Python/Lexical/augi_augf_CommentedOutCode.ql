/**
 * @name Commented-out code detection
 * @description Finds commented code sections that could impact code quality by making it harder to read and maintain.
 * @kind problem
 * @tags maintainability
 *       readability
 *       documentation
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/commented-out-code
 */

// Import required modules
import python
import Lexical.CommentedOutCode

// Query to identify commented-out code blocks that are not example code
from CommentedOutCodeBlock commentedCodeSection
where not commentedCodeSection.maybeExampleCode()
select commentedCodeSection, "This comment appears to contain commented-out code."