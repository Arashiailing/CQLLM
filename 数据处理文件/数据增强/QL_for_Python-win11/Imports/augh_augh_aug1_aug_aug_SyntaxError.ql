/**
 * @name Python Syntax Error Detection
 * @description Identifies Python code containing syntax errors that cause runtime failures and impede static analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error */

import python

// Retrieve syntax errors while excluding encoding-related issues
from SyntaxError syntaxErr
where not (syntaxErr instanceof EncodingError)

// Generate error message with Python version context
select syntaxErr, 
       syntaxErr.getMessage() + " (in Python " + major_version() + ")."