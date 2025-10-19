/**
 * @name Commented-out code
 * @description Detects code segments that have been commented out by developers, which can degrade code readability and impede long-term maintenance efforts.
 * @kind problem
 * @tags maintainability
 *       readability
 *       documentation
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/commented-out-code */

// Import the Python language analysis module
import python

// Import the CommentedOutCode class from Lexical module for detecting commented code
import Lexical.CommentedOutCode

// Identify problematic commented code blocks
from CommentedOutCodeBlock problematicCommentBlock
// Exclude blocks that might represent example code or documentation
where not problematicCommentBlock.maybeExampleCode()
// Report the identified commented code blocks with an appropriate warning message
select problematicCommentBlock, "This comment appears to contain commented-out code."