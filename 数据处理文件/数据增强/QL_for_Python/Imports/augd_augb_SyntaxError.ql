/**
 * @name Syntax error detection
 * @description Detects Python syntax errors that can cause runtime failures and impede static code analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// Import the Python library for code analysis and query processing
import python

// Query for syntax error instances, filtering out encoding-related issues
from SyntaxError syntaxFailure
where 
  // Exclude encoding-related errors from the results
  not syntaxFailure instanceof EncodingError
select 
  syntaxFailure, 
  // Format the error message to include Python version information
  syntaxFailure.getMessage() + " (detected in Python " + major_version() + ")."