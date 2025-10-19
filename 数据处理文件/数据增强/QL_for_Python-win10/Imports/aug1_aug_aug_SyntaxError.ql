/**
 * @name Python Syntax Error Detection
 * @description Identifies Python code with syntax errors that cause runtime failures and hinder code analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error */

import python

// Identify syntax errors while excluding encoding-related issues
from SyntaxError err
where not err instanceof EncodingError
// Return error details with Python version context
select err, err.getMessage() + " (in Python " + major_version() + ")."