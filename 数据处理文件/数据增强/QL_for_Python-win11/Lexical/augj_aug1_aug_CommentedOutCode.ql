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

// Import Python analysis library for code parsing and evaluation
import python

// Import CommentedOutCode class from Lexical module to detect commented code fragments
import Lexical.CommentedOutCode

// Primary query logic to locate problematic commented code blocks
from CommentedOutCodeBlock commentedBlock
// Exclusion filter: skip blocks that represent example code or documentation
where not commentedBlock.maybeExampleCode()
// Report identified commented code blocks with warning message
select commentedBlock, "This comment appears to contain commented-out code."