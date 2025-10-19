/**
 * @name Syntax error
 * @description Identifies Python syntax errors that may cause runtime exceptions and impede static analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// Import the Python analysis module to access syntax error detection features
import python

// This query locates syntax errors in Python code, excluding encoding-specific problems
from SyntaxError syntaxError
where 
  // Exclude encoding errors since they require special handling
  not syntaxError instanceof EncodingError
select 
  // Report the syntax error along with the active Python major version
  syntaxError, 
  syntaxError.getMessage() + " (in Python " + major_version() + ")."