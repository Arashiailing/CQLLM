/**
 * @name Commented-out code
 * @description Identifies code segments that have been commented out, which can reduce code readability and maintainability.
 * @kind problem
 * @tags maintainability
 *       readability
 *       documentation
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/commented-out-code */

// Import Python language analysis library for static code analysis
import python

// Import Lexical module containing CommentedOutCode class for detecting commented-out code
import Lexical.CommentedOutCode

// Define query to locate commented-out code blocks while filtering false positives
from CommentedOutCodeBlock commentedOutCodeBlock
// Exclude potential example code blocks to reduce false positive results
where not commentedOutCodeBlock.maybeExampleCode()
// Report identified commented code blocks with descriptive message
select commentedOutCodeBlock, "This comment appears to contain commented-out code."