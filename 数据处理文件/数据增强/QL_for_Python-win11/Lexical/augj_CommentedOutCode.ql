/**
 * @name Commented-out code
 * @description Identifies code blocks that have been commented out, which can reduce code readability
 *              and maintainability by cluttering the source with inactive code.
 * @kind problem
 * @tags maintainability
 *       readability
 *       documentation
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/commented-out-code
 */

// Import Python language support library
import python

// Import lexical analysis capabilities for detecting commented code
import Lexical.CommentedOutCode

// Identify all commented-out code blocks that are not likely examples
from CommentedOutCodeBlock commentedBlock
where 
  // Exclude code blocks that appear to be documentation examples
  not commentedBlock.maybeExampleCode()
select 
  commentedBlock, 
  "This comment appears to contain commented-out code."