/**
 * @name Commented-out code
 * @description Commented-out code makes the remaining code more difficult to read.
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

// Import lexical analysis components for commented code detection
import Lexical.CommentedOutCode

// Identify code blocks containing commented-out code
from CommentedOutCodeBlock commentedBlock
// Exclude blocks that may represent example code
where not commentedBlock.maybeExampleCode()
// Report detected commented-out code blocks with descriptive message
select commentedBlock, "This comment appears to contain commented-out code."