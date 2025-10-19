/**
 * @name Syntax error detection
 * @description Identifies syntax errors that lead to runtime failures and hinder code analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// Import Python library for code analysis and query processing
import python

// Select syntax error instances, excluding encoding-related errors
from SyntaxError syntaxIssue
where not syntaxIssue instanceof EncodingError
select syntaxIssue, syntaxIssue.getMessage() + " (in Python " + major_version() + ")."
// Output syntax error details along with the current Python major version information