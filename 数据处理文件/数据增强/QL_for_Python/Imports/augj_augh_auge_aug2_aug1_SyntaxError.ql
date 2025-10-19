/**
 * @name Syntax error
 * @description Identifies Python syntax errors that cause runtime failures and impede code analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// Import Python analysis module for syntax error detection
import python

// Find all syntax issues excluding encoding-related problems
from SyntaxError syntaxIssue
where 
  // Exclude encoding errors to focus on actual syntax violations
  not syntaxIssue instanceof EncodingError
select 
  // Report the syntax issue location with contextual information
  syntaxIssue, 
  // Generate detailed error message including Python version context
  syntaxIssue.getMessage() + " (in Python " + major_version() + ")."