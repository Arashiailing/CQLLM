/**
 * @name Commented-out code
 * @description Detects code segments that have been deactivated through commenting.
 *              Commented-out code can reduce readability and maintainability,
 *              as it often becomes outdated and may confuse developers about
 *              the intended functionality of the codebase.
 * @kind problem
 * @tags maintainability
 *       readability
 *       documentation
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/commented-out-code */

// Import necessary modules for Python code analysis
import python
import Lexical.CommentedOutCode

// Identify all commented-out code blocks in the codebase
from CommentedOutCodeBlock commentedOutCode
// Exclude blocks that are likely example code to reduce false positives
where not commentedOutCode.maybeExampleCode()
// Report the identified commented-out code blocks with a descriptive message
select commentedOutCode, "This comment appears to contain commented-out code."