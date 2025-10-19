/**
 * @name Python Syntax Error Detection
 * @description Detects Python files containing syntax errors that lead to execution failures and impede static analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error */

import python

// Locate syntax errors in Python code, excluding encoding-related problems
from SyntaxError synErr
where 
  // Exclude encoding-related errors from our analysis
  not synErr instanceof EncodingError
select 
  synErr, 
  // Include Python version context in the error message
  synErr.getMessage() + " (in Python " + major_version() + ")."