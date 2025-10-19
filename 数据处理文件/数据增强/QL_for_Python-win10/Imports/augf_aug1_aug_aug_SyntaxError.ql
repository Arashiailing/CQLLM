/**
 * @name Python Syntax Error Detection
 * @description Detects Python source code containing syntax errors that lead to runtime failures
 *              and impede static code analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error */

import python

// Identify syntax errors in Python code, excluding encoding-related issues
from SyntaxError pythonSyntaxError
where 
  // Exclude encoding errors as they are not the focus of this analysis
  not pythonSyntaxError instanceof EncodingError
// Return error details along with the Python version context for better understanding
select pythonSyntaxError, pythonSyntaxError.getMessage() + " (in Python " + major_version() + ")."