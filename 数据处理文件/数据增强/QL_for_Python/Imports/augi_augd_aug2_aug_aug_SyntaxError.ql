/**
 * @name Python Syntax Error Detection
 * @description This query identifies Python syntax errors that could potentially cause runtime failures
 *              and impede effective static analysis. It specifically targets syntax issues while
 *              excluding encoding-related problems to focus on core syntax violations.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// Import the core Python analysis module for syntax error detection
import python

// Identify syntax errors in Python code, excluding encoding-related issues
from SyntaxError pySyntaxIssue
where 
  // Filter out encoding errors to focus on pure syntax problems
  not pySyntaxIssue instanceof EncodingError
// Generate a detailed error message including the Python version context
select pySyntaxIssue, pySyntaxIssue.getMessage() + " (in Python " + major_version() + ")."