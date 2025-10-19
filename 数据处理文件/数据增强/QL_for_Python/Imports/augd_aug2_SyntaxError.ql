/**
 * @name Syntax error detection
 * @description Identifies Python syntax errors that can cause runtime failures and 
 *              prevent proper code analysis. This query specifically excludes 
 *              encoding-related errors to focus on core syntax issues.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// Import the Python module to enable analysis of Python source code
import python

// Query for syntax error instances in the codebase
from SyntaxError syntaxErrorInstance
// Filter out encoding-related errors to focus on core syntax issues
where not syntaxErrorInstance instanceof EncodingError
// Output the syntax error along with its descriptive message and the Python major version
select syntaxErrorInstance, syntaxErrorInstance.getMessage() + " (in Python " + major_version() + ")."