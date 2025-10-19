/**
 * @name Python syntax error detection
 * @description Identifies Python syntax errors that may lead to runtime failures and hinder static analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// Import the Python module for code analysis functionality
import python

// Query to identify syntax errors while excluding encoding-related issues
from SyntaxError pySyntaxError
where not pySyntaxError instanceof EncodingError
select pySyntaxError, pySyntaxError.getMessage() + " (detected in Python " + major_version() + ")."
// Output includes the error message and the Python major version in which it was detected