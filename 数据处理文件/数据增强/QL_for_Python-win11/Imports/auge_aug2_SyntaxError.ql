/**
 * @name Syntax error detection
 * @description Detects syntax errors in Python code that can cause runtime failures
 *              and hinder static code analysis. This query excludes encoding-related
 *              errors to focus on pure syntax issues.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// Import the Python module for source code analysis
import python

// Identify syntax errors that are not related to encoding issues
from SyntaxError syntaxError
where not syntaxError instanceof EncodingError
select syntaxError, syntaxError.getMessage() + " (in Python " + major_version() + ")."
// Display the syntax error with its message and the current Python major version