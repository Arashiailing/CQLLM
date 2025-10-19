/**
 * @name Dead code in comments
 * @description Identifies commented-out code blocks that reduce code readability and maintainability.
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

// Import lexical analysis utilities for comment detection
import Lexical.CommentedOutCode

// Identify commented code blocks excluding documentation examples
from CommentedOutCodeBlock deadCodeBlock
where not deadCodeBlock.maybeExampleCode()

// Report detected dead code blocks with explanatory message
select deadCodeBlock, "This comment contains commented-out code that should be removed."