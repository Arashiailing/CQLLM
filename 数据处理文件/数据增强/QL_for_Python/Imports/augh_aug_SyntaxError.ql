/**
 * @name Syntax error detection
 * @description Identifies Python syntax errors that lead to runtime failures and hinder proper code analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// Import the Python library required for code querying and analysis
import python

// Query for syntax errors, filtering out encoding-related issues
from SyntaxError syntaxProblem
where not syntaxProblem instanceof EncodingError
select syntaxProblem, syntaxProblem.getMessage() + " (in Python " + major_version() + ")."
// Output the syntax error instance along with a detailed error message including the Python version