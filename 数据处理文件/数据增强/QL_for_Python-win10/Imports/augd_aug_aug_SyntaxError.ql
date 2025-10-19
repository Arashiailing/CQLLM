/**
 * @name Python Syntax Error Detection
 * @description Detects Python code containing syntax errors that cause runtime failures and hinder code analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// Import the Python module providing core analysis classes and predicates
import python

// Identify syntax errors while excluding encoding-related issues
from SyntaxError error
where 
  // Filter out encoding errors to focus on syntax issues
  not error instanceof EncodingError
// Format error message with Python version context
select error, 
       error.getMessage() + " (in Python " + major_version() + ")."