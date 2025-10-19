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

// Import the Python module to enable analysis of Python source code
import python

// Define the query to find syntax errors, excluding those related to encoding issues
from SyntaxError syntaxIssue
where 
  // Filter out encoding-related errors as they are a separate category of issues
  not syntaxIssue instanceof EncodingError
select 
  syntaxIssue, 
  // Format the error message with Python version information
  syntaxIssue.getMessage() + " (in Python " + major_version() + ")."