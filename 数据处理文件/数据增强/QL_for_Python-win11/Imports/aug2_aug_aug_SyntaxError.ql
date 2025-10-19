/**
 * @name Python Syntax Error Detection
 * @description Detects Python syntax errors that may lead to runtime failures and impede code analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// Import essential Python analysis module
import python

// Identify all syntax errors in the codebase, excluding encoding-related issues
from SyntaxError pySyntaxIssue
where not pySyntaxIssue instanceof EncodingError
// Format a comprehensive error message including Python version information
select pySyntaxIssue, pySyntaxIssue.getMessage() + " (in Python " + major_version() + ")."