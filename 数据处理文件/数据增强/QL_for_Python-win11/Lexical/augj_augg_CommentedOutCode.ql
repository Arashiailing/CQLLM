/**
 * @name Commented-out code detection
 * @description Detects code blocks that appear to contain commented-out code, 
 *              which can negatively impact code readability and maintainability.
 * @kind problem
 * @tags maintainability
 *       readability
 *       documentation
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/commented-out-code
 */

// Import Python language analysis capabilities
import python

// Import lexical analysis utilities for commented code identification
import Lexical.CommentedOutCode

// Identify code blocks containing commented-out code (excluding example code)
from CommentedOutCodeBlock commentedCodeBlock
where 
  // Filter out potential example code blocks
  not commentedCodeBlock.maybeExampleCode()
// Report detected commented code blocks with explanatory message
select commentedCodeBlock, "This comment appears to contain commented-out code."