/**
 * @name Python Syntax Error Detection
 * @description Detects Python source files containing syntax errors that lead to runtime exceptions and impede static analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// Import the Python analysis module providing essential classes and predicates for Python code examination
import python

// Main query logic:
// 1. Identify syntax errors in the codebase
// 2. Exclude encoding-related errors
// 3. Return error details with Python version context
from SyntaxError syntaxErr
where not syntaxErr instanceof EncodingError
select syntaxErr, syntaxErr.getMessage() + " (in Python " + major_version() + ")."