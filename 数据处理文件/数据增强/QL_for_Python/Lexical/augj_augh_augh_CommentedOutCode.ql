/**
 * @name Commented-out code
 * @description Detects source code that has been disabled via comments, which can negatively impact
 * code quality by leaving outdated or non-functional code fragments in the codebase.
 * @kind problem
 * @tags maintainability
 *       readability
 *       documentation
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/commented-out-code */

// Import Python language support for code analysis
import python

// Import lexical analysis capabilities for detecting commented code
import Lexical.CommentedOutCode

// Define the main query to identify commented-out code sections
from CommentedOutCodeBlock commentedOutCode
// Apply filtering criteria to exclude blocks that are likely documentation or examples
where not commentedOutCode.maybeExampleCode()
// Generate results for each qualifying commented code block
select commentedOutCode, "This comment contains commented-out code that should be removed to improve code maintainability."