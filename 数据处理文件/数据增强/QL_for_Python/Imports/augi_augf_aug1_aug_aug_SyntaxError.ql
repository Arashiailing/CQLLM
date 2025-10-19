/**
 * @name Python Syntax Error Detection
 * @description Identifies Python source code with syntax errors that cause runtime failures
 *              and obstruct static analysis capabilities.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error */

import python

// Find syntax errors while excluding encoding-related issues
from SyntaxError syntaxErr
where 
  // Filter out encoding errors as they are not the target of this analysis
  not syntaxErr instanceof EncodingError
// Generate output with error details and Python version context
select syntaxErr, syntaxErr.getMessage() + " (in Python " + major_version() + ")."