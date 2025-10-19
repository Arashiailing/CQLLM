/**
 * @name Commented-out code
 * @description Detects code blocks containing commented-out source code, which
 *              negatively impacts code readability and maintainability.
 * @kind problem
 * @tags maintainability
 *       readability
 *       documentation
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/commented-out-code
 */

// Import Python language support for code analysis
import python

// Import lexical analysis utilities for commented code detection
import Lexical.CommentedOutCode

// Identify commented-out code blocks, excluding potential examples
from CommentedOutCodeBlock commentedOutBlock
where not commentedOutBlock.maybeExampleCode()
// Report the location of problematic commented code
select commentedOutBlock, "This comment appears to contain commented-out code."