/**
 * @name Detection of Python syntax errors
 * @description Locates syntax errors in Python code that can cause execution failures and impede static analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// Import the Python module to enable code analysis capabilities
import python

// Find all syntax errors, filtering out encoding-specific issues
from SyntaxError syntaxErr
where not syntaxErr instanceof EncodingError
select syntaxErr, syntaxErr.getMessage() + " (detected in Python " + major_version() + ")."
// Display the error message along with the major version of Python being analyzed