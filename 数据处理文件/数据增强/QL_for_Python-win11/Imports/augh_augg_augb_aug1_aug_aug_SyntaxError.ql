/**
 * @name Python Syntax Error Detection
 * @description Identifies Python source code with syntax errors that cause runtime exceptions
 *              and obstruct static analysis capabilities. Encoding-related issues are excluded
 *              as they represent file/encoding problems rather than actual syntax defects.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error */

import python

// This query targets syntax errors in Python code that could trigger runtime exceptions
// and impede static analysis. Encoding errors are deliberately excluded since they
// stem from file encoding or character set issues, not genuine syntax problems.
from SyntaxError synErr
where 
  // Excluding encoding-related errors as they represent file/encoding issues
  // rather than actual syntax defects in the code structure
  not synErr instanceof EncodingError
select 
  synErr, 
  // Error message includes Python version context for developer troubleshooting
  synErr.getMessage() + " (in Python " + major_version() + ")."