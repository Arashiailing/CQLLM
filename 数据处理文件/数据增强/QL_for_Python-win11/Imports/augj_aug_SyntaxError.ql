/**
 * @name Syntax error
 * @description Identifies Python syntax errors that lead to runtime failures and hinder proper code analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// Import the Python library required for code analysis and querying
import python

// Find syntax errors in Python code, excluding those related to encoding issues
from SyntaxError syntaxErr
where 
  // Exclude encoding-related errors from our results
  not syntaxErr instanceof EncodingError
select 
  syntaxErr, 
  // Format the error message to include the Python version information
  syntaxErr.getMessage() + " (in Python " + major_version() + ")."
// Output the syntax error instance along with a descriptive message including the Python version