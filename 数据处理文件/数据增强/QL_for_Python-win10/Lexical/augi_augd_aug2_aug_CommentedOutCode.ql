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

// Query to find commented-out code blocks, excluding potential examples to minimize false positives
from CommentedOutCodeBlock commentedBlock
where not commentedBlock.maybeExampleCode()
// Output the identified commented code blocks with an informative message
select commentedBlock, "This comment appears to contain commented-out code."