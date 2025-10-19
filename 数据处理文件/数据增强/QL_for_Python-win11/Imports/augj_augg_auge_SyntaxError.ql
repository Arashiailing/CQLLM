/**
 * @name Syntax error
 * @description Detects Python syntax errors that lead to runtime failures
 *              and obstruct proper code analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// Import Python analysis framework for code querying capabilities
import python

// Query for syntax issues in Python codebase
from SyntaxError syntaxIssue
where 
  // Filter out encoding-related errors to focus on genuine syntax problems
  not syntaxIssue instanceof EncodingError
select 
  syntaxIssue, 
  // Construct detailed error message including Python version context
  syntaxIssue.getMessage() + " (in Python " + major_version() + ")."
// Output syntax error details with version-specific information