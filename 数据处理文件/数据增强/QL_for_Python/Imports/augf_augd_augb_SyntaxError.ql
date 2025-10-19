/**
 * @name Syntax error detection
 * @description Identifies Python syntax errors that may cause runtime failures and obstruct static analysis
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// Import core Python analysis capabilities
import python

// Identify syntax error occurrences while excluding encoding-related issues
from SyntaxError syntaxErr
where 
  // Filter out encoding-specific error types
  not syntaxErr instanceof EncodingError
select 
  syntaxErr, 
  // Construct error message with Python version context
  syntaxErr.getMessage() + " (detected in Python " + major_version() + ")."