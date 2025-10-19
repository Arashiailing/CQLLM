/**
 * @name Commented-out code detection
 * @description Identifies code segments that have been commented out, which can reduce code readability and maintainability.
 * @kind problem
 * @tags maintainability
 *       readability
 *       documentation
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/commented-out-code */

// Import core Python analysis capabilities for static code inspection
import python

// Import lexical analysis module specifically for detecting commented code patterns
import Lexical.CommentedOutCode

// Main query to identify commented-out code blocks while filtering example code
from CommentedOutCodeBlock commentedOutCodeBlock
where 
  // Exclude blocks that represent example code to minimize false positives
  not commentedOutCodeBlock.maybeExampleCode()
// Report identified blocks with standardized diagnostic message
select commentedOutCodeBlock, "This comment appears to contain commented-out code."