/**
 * @name Syntax error
 * @description Identifies syntax errors that lead to runtime failures and impede code analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// Import Python language analysis module for syntax tree construction, parsing, and error detection
import python

// This query identifies syntax errors in Python code that prevent proper parsing and execution.
// Encoding errors are excluded as they relate to file parsing, not syntax structure issues.
from SyntaxError syntaxIssue
where not syntaxIssue instanceof EncodingError
// The result includes the syntax error object and a detailed message with Python version info.
select syntaxIssue, syntaxIssue.getMessage() + " (in Python " + major_version() + ")."