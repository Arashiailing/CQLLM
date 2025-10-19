/**
 * @name Commented-out code detection
 * @description Detects code segments that have been commented out in Python source files.
 *              Such commented code can negatively impact code readability and maintainability,
 *              potentially indicating dead code or temporary solutions that were never properly addressed.
 * @kind problem
 * @tags maintainability
 *       readability
 *       documentation
 *       code-quality
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/commented-out-code */

// Import fundamental Python analysis capabilities for comprehensive static code inspection
import python

// Import specialized lexical analysis module designed for identifying patterns of commented-out code
import Lexical.CommentedOutCode

// Define the source of commented code blocks for analysis
from CommentedOutCodeBlock commentedBlock

// Apply filtering conditions to exclude false positives and focus on genuine commented-out code
where 
  // Filter out blocks that might represent example code or documentation snippets
  not commentedBlock.maybeExampleCode()

// Report the identified commented-out code blocks with a standardized diagnostic message
select commentedBlock, "This comment appears to contain commented-out code."