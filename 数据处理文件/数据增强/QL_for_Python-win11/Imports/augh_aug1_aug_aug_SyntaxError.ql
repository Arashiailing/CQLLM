/**
 * @name Python Syntax Error Detection
 * @description Detects Python code containing syntax errors that lead to runtime failures and impede code analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error */

import python

// Find all syntax errors in the codebase
from SyntaxError pySyntaxError

// Exclude encoding-related errors as they are not true syntax issues
where not pySyntaxError instanceof EncodingError

// Format the error message with Python version information
select pySyntaxError, pySyntaxError.getMessage() + " (in Python " + major_version() + ")."