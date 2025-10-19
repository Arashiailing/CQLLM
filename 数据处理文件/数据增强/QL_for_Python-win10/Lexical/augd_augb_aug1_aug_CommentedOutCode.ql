/**
 * @name Commented-out code
 * @description Detects code segments that were commented out during development. 
 *              This practice often leads to decreased code clarity and maintenance
 *              difficulties, as inactive code accumulates and potentially confuses
 *              developers about the intended functionality.
 * @kind problem
 * @tags maintainability
 *       readability
 *       documentation
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/commented-out-code */

// Import necessary modules for Python code analysis
import python

// Import the CommentedOutCode class from the Lexical module for comment analysis
import Lexical.CommentedOutCode

// Main query logic to identify problematic commented code segments
from CommentedOutCodeBlock commentedCodeSegment
// Filter out legitimate examples or documentation comments to reduce false positives
where not commentedCodeSegment.maybeExampleCode()
// Output the identified commented code segments with an appropriate alert message
select commentedCodeSegment, "This comment appears to contain commented-out code."