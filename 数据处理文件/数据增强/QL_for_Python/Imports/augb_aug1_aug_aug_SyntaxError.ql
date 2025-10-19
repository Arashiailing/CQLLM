/**
 * @name Python Syntax Error Detection
 * @description Detects Python source code containing syntax errors that lead to runtime exceptions and impede static analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error */

import python

// This query identifies syntax errors in Python code, specifically excluding encoding-related errors
// which are typically handled differently and don't represent actual syntax issues
from SyntaxError syntaxIssue
where 
  // Exclude encoding-related errors as they are not true syntax issues
  not syntaxIssue instanceof EncodingError
select 
  syntaxIssue, 
  // Include Python version in the error message for context
  syntaxIssue.getMessage() + " (in Python " + major_version() + ")."