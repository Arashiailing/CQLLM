/**
 * @name Syntax error
 * @description Identifies Python syntax errors that would cause runtime failures
 *              and prevent code analysis. Excludes encoding-related issues.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// Import Python language analysis module for syntax error detection capabilities
import python

// Identify all syntax errors that are not encoding-related
from SyntaxError errorInstance
where not errorInstance instanceof EncodingError

// Output the syntax error with detailed message and current Python major version
select errorInstance, errorInstance.getMessage() + " (in Python " + major_version() + ")."