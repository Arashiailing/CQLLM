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

// Select code blocks that appear to contain commented-out code (excluding examples)
from CommentedOutCodeBlock commentedBlock
where not commentedBlock.maybeExampleCode()
// Report the identified commented code blocks with a descriptive message
select commentedBlock, "This comment appears to contain commented-out code."