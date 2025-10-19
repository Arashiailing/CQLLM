/**
 * @name Commented-out code detection
 * @description Identifies code segments that developers have commented out, 
 * which can reduce code readability and hinder long-term maintenance.
 * @kind problem
 * @tags maintainability
 *       readability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/commented-out-code */

// Standard Python language analysis imports
import python

// Lexical analysis module for detecting commented code patterns
import Lexical.CommentedOutCode

/*
 * Implementation approach:
 * 1. Identify potential commented code blocks
 * 2. Filter out legitimate documentation or examples
 * 3. Generate warning for remaining problematic blocks
 */

// 1. Source: All commented code blocks that might be problematic
from CommentedOutCodeBlock suspiciousCommentedCode

// 2. Filter: Exclude blocks that are likely documentation or examples
where not suspiciousCommentedCode.maybeExampleCode()

// 3. Output: Report findings with consistent warning message
select suspiciousCommentedCode, "This comment appears to contain commented-out code."