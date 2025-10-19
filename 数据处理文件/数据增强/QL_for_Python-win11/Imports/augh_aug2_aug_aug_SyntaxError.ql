/**
 * @name Python Syntax Error Detection
 * @description Identifies Python syntax errors that could cause runtime failures and hinder code analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// Import core Python analysis module
import python

// Locate all syntax errors in the codebase, excluding encoding-related issues
from SyntaxError syntaxErr
where
  // Exclude encoding errors from syntax error detection
  not syntaxErr instanceof EncodingError
// Generate detailed error message with Python version context
select syntaxErr, syntaxErr.getMessage() + " (in Python " + major_version() + ")."