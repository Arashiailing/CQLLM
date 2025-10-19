/**
 * @name Python Syntax Error Detection
 * @description Detects Python code containing syntax errors that lead to runtime failures and obstruct code analysis
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error */

import python

// Locate syntax errors while filtering out encoding-related problems
from SyntaxError syntaxErr
where not syntaxErr instanceof EncodingError
// Provide error details with Python version information
select syntaxErr, syntaxErr.getMessage() + " (in Python " + major_version() + ")."