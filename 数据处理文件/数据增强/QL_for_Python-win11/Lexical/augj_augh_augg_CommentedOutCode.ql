/**
 * @name Commented-out code
 * @description Detects commented code blocks that impair readability and maintainability
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

// Import lexical analysis utilities for commented code detection
import Lexical.CommentedOutCode

// Filter commented code blocks excluding example code
from CommentedOutCodeBlock commentedBlock
where not commentedBlock.maybeExampleCode()
// Report findings with contextual message
select commentedBlock, "This comment appears to contain commented-out code."