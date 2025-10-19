/**
 * @name Syntax error
 * @description Identifies syntax errors that lead to runtime failures and hinder code analysis.
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

// Define the set of syntax errors excluding encoding-related issues
from SyntaxError syntaxIssue
where 
  // Exclude encoding-related errors
  not syntaxIssue instanceof EncodingError

// Prepare the error message with Python version information
// and output the syntax error with detailed message
select syntaxIssue, 
       syntaxIssue.getMessage() + " (in Python " + major_version() + ")."