/**
 * @name Syntax error
 * @description Detects syntax errors in Python code that lead to runtime failures and hinder code analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// Import the Python language analysis module for detecting syntax errors in code
import python

// Identify all syntax errors that are not related to encoding issues
// This allows focusing on actual syntax problems rather than file encoding mismatches
from SyntaxError syntaxError
where 
  // Filter out encoding-related errors to concentrate on pure syntax violations
  not syntaxError instanceof EncodingError
select 
  // Return the syntax error location along with a descriptive message
  syntaxError, 
  // Construct a detailed error message including the Python version context
  syntaxError.getMessage() + " (in Python " + major_version() + ")."