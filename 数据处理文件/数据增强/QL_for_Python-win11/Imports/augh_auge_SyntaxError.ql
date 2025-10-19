/**
 * @name Syntax error detection
 * @description Identifies syntax errors in Python code that can cause runtime failures
 *              and impede static code analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// Import the Python analysis module for code querying capabilities
import python

// Identify syntax error instances, excluding encoding-related errors
from SyntaxError syntaxFailure
where 
  // Filter out encoding errors to focus on pure syntax issues
  not syntaxFailure instanceof EncodingError
select 
  syntaxFailure, 
  syntaxFailure.getMessage() + " (in Python " + major_version() + ")."