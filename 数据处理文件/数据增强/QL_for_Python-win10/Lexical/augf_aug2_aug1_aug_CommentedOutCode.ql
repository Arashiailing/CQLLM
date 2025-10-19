/**
 * @name Commented-out code detection
 * @description Identifies code segments that developers have commented out, 
 * which can reduce code readability and hinder long-term maintenance.
 * @kind problem
 * @tags maintainability
 *       readability
 *       documentation
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/commented-out-code */

// Import Python language analysis capabilities
import python

// Import lexical analysis module for commented code detection
import Lexical.CommentedOutCode

// Core query logic: identify problematic commented code blocks
from CommentedOutCodeBlock problematicCommentedBlock

// Filter out blocks that might be documentation or example code
where not problematicCommentedBlock.maybeExampleCode()

// Report findings with standardized warning message
select problematicCommentedBlock, "This comment appears to contain commented-out code."