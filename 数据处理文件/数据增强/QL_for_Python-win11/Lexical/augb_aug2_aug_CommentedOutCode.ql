/**
 * @name Commented-out code
 * @description Detects commented-out code segments that may degrade readability and maintainability.
 * @kind problem
 * @tags maintainability
 *       readability
 *       documentation
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/commented-out-code */

// Import core Python analysis capabilities
import python

// Import lexical analysis utilities for comment detection
import Lexical.CommentedOutCode

// Identify commented code blocks excluding example code
from CommentedOutCodeBlock commentedBlock
where not commentedBlock.maybeExampleCode()
// Report findings with descriptive message
select commentedBlock, "This comment appears to contain commented-out code."