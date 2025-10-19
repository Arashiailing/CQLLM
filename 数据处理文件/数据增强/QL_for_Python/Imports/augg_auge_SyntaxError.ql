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

// Import Python analysis module for code querying capabilities
import python

// Identify syntax errors in Python code, excluding encoding-related issues
from SyntaxError syntaxErr
where 
  // Exclude encoding errors to focus on actual syntax problems
  not syntaxErr instanceof EncodingError
select 
  syntaxErr, 
  syntaxErr.getMessage() + " (in Python " + major_version() + ")."
// Display error details along with the Python major version information