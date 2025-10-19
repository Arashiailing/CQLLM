/**
 * @name Syntax error detection
 * @description Detects Python syntax errors that could cause runtime failures
 *              and hinder static analysis. This query excludes encoding-related
 *              issues to focus specifically on actual syntax problems.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// Import the Python module for analyzing source code
import python

// Find syntax errors in Python source files
from SyntaxError syntaxIssue
// Exclude encoding-related errors to concentrate on pure syntax issues
where not (syntaxIssue instanceof EncodingError)
// Present the syntax error along with its message and Python version
select syntaxIssue, syntaxIssue.getMessage() + " (in Python " + major_version() + ")."