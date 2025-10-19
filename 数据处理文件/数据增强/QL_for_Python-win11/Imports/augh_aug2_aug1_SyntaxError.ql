/**
 * @name Syntax error
 * @description Detects syntax errors in Python code that can lead to runtime failures and hinder code analysis.
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

// Query to identify syntax errors excluding encoding-related issues
from SyntaxError syntaxIssue
where 
  // Filter out encoding errors as they are handled separately
  not syntaxIssue instanceof EncodingError
select 
  // Output syntax error details along with the current Python major version
  syntaxIssue, 
  syntaxIssue.getMessage() + " (in Python " + major_version() + ")."