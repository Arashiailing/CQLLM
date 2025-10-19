/**
 * @name Syntax error
 * @description Detects syntax errors in Python code that can cause runtime failures
 *              and prevent proper code analysis. Excludes encoding-related errors.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// Import the Python language module which provides syntax error detection capabilities
import python

// Define the source of syntax issues, excluding encoding errors
from SyntaxError syntaxIssue
where 
  // Filter out encoding-related errors to focus on pure syntax problems
  not syntaxIssue instanceof EncodingError
// Generate the result with error message and current Python version context
select syntaxIssue, 
       syntaxIssue.getMessage() + " (detected in Python " + major_version() + ")."