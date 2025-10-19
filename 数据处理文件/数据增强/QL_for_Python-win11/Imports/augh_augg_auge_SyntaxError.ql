/**
 * @name Syntax error
 * @description Detects Python syntax errors that lead to runtime failures and obstruct comprehensive code analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// Import the Python analysis module to enable code querying and syntax error detection
import python

// Query to identify syntax issues in Python source code
from SyntaxError syntaxIssue
where 
  // Filter out encoding-related errors to focus on genuine syntax problems
  not syntaxIssue instanceof EncodingError
select 
  syntaxIssue, 
  syntaxIssue.getMessage() + " (in Python " + major_version() + ")."
// Output the syntax error details combined with the major version of Python being analyzed