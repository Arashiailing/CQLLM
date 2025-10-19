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

// This query identifies syntax errors in Python code that could lead to runtime
// exceptions and hinder static analysis. Encoding-related errors are excluded
// as they are typically handled differently and don't represent actual syntax issues.
from SyntaxError syntaxError
where 
  // We filter out encoding-related errors since they are not genuine syntax problems
  // but rather issues related to file encoding or character sets
  not syntaxError instanceof EncodingError
select 
  syntaxError, 
  // The error message includes the Python version to provide context for developers
  syntaxError.getMessage() + " (in Python " + major_version() + ")."