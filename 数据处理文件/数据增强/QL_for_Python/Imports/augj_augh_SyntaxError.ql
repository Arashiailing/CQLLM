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

// Import Python analysis module for syntax parsing and error detection capabilities
import python

// Identify all Python syntax errors, excluding encoding-related issues
from SyntaxError syntaxIssue
where 
  // Exclude encoding errors from our analysis
  not syntaxIssue instanceof EncodingError
select 
  // Return the syntax error object along with detailed information
  syntaxIssue, 
  // Construct error message including the current Python major version
  syntaxIssue.getMessage() + " (in Python " + major_version() + ")."