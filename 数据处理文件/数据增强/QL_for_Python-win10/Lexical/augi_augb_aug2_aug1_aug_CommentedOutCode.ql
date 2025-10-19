/**
 * @name Commented-out code
 * @description Identifies code segments that developers have commented out, which can reduce code readability and hinder long-term maintenance.
 * @kind problem
 * @tags maintainability
 *       readability
 *       documentation
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/commented-out-code */

// Import Python language analysis library
import python

// Import lexical analysis module for commented code detection
import Lexical.CommentedOutCode

// Identify problematic commented code blocks
from CommentedOutCodeBlock problematicCommentedCode
// Filter out documentation examples and sample code
where not problematicCommentedCode.maybeExampleCode()
// Report findings with maintenance warning
select problematicCommentedCode, "This comment appears to contain commented-out code."