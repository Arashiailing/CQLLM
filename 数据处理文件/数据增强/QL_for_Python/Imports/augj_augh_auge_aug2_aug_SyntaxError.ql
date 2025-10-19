/**
 * @name Syntax error detection
 * @description Identifies Python syntax errors that cause runtime failures and impede precise code analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// Import core Python analysis components for syntax error detection
import python

// Identify syntax errors while excluding encoding-related issues
from SyntaxError syntaxError
where 
  // Filter out encoding-specific syntax errors
  not syntaxError instanceof EncodingError

// Generate detailed error report with version context
select 
  syntaxError, 
  syntaxError.getMessage() + " (in Python " + major_version() + ")."