/**
 * @name Python Syntax Error Detection
 * @description Identifies Python source files containing syntax errors that cause runtime exceptions
 *              and hinder static analysis capabilities. Excludes encoding-related issues which
 *              are typically handled separately and don't represent actual syntax problems.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error */

import python

// Identify syntax errors while excluding encoding-related issues
from SyntaxError syntaxError
where 
  // Filter out encoding errors as they represent configuration issues rather than syntax problems
  not syntaxError instanceof EncodingError
select 
  syntaxError, 
  // Augment error message with Python version context for better diagnostics
  syntaxError.getMessage() + " (in Python " + major_version() + ")."