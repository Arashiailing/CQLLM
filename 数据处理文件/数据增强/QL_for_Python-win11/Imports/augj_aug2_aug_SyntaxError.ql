/**
 * @name Syntax error
 * @description Identifies Python syntax errors that cause runtime failures and impede proper code analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// Import the Python module for AST-based code analysis and querying
import python

// Query to detect syntax errors in Python source code
// Excludes encoding errors to focus on pure syntax issues
from SyntaxError syntaxErr
where 
  // Filter out encoding-related errors as they require different handling
  not syntaxErr instanceof EncodingError
select 
  syntaxErr, 
  // Generate a detailed error message including Python version information
  syntaxErr.getMessage() + " (in Python " + major_version() + ")."