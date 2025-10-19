/**
 * @name Commented-out code
 * @description Identifies code blocks that have been commented out, which can reduce code readability and maintainability.
 * @kind problem
 * @tags maintainability
 *       readability
 *       documentation
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/commented-out-code
 */

// Import Python language support
import python

// Import lexical analysis for commented code detection
import Lexical.CommentedOutCode

// Identify commented-out code blocks that are not examples
from CommentedOutCodeBlock commentedOutCodeBlock
where not commentedOutCodeBlock.maybeExampleCode()
// Report the identified commented code blocks with a descriptive message
select commentedOutCodeBlock, "This comment appears to contain commented-out code."