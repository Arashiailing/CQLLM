/**
 * @name Syntax error detection
 * @description Identifies syntax errors that lead to runtime failures and impede code analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// Import Python module for analyzing Python source code
import python

// Select syntax error instances, excluding encoding-related errors
from SyntaxError syntaxErr
where not syntaxErr instanceof EncodingError
select syntaxErr, syntaxErr.getMessage() + " (in Python " + major_version() + ")."
// Output the syntax error along with its message and the current Python major version