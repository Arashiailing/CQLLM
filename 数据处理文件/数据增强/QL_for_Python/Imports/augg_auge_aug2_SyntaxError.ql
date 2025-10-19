/**
 * @name Syntax error detection
 * @description Identifies Python syntax errors that may lead to runtime failures
 *              and impede static analysis. This query specifically filters out
 *              encoding-related issues to concentrate on genuine syntax problems.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// Import the Python module for source code analysis
import python

// Identify syntax issues in Python code
from SyntaxError syntaxProblem
// Filter out encoding-related errors to focus on pure syntax problems
where not syntaxProblem instanceof EncodingError
// Display the syntax problem with its message and Python version info
select syntaxProblem, syntaxProblem.getMessage() + " (in Python " + major_version() + ")."