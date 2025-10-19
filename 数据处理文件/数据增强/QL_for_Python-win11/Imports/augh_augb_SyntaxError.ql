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

// Import the Python module to enable analysis of Python source code
import python

// Identify syntax errors that can cause runtime failures
from SyntaxError syntaxError
where 
    // Exclude encoding errors as they represent a distinct category of issues
    not syntaxError instanceof EncodingError

// Present the syntax error details along with the Python version context
select syntaxError, 
       // Format the output to include both the error message and Python version
       syntaxError.getMessage() + " (in Python " + major_version() + ")."