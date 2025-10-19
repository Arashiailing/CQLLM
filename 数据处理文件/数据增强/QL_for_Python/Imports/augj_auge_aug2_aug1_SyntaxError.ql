/**
 * @name Syntax error
 * @description Identifies Python syntax errors that can cause runtime exceptions and impede static code analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// Import the Python language analysis module for syntax error detection
import python

// Define a variable to represent syntax problems in Python code
from SyntaxError syntaxProblem
// Exclude encoding-related errors from our analysis
where not syntaxProblem instanceof EncodingError
// Output the syntax error with its descriptive message and Python version context
select syntaxProblem, syntaxProblem.getMessage() + " (in Python " + major_version() + ")."