/**
 * @name Syntax error
 * @description Detects Python syntax errors that lead to runtime failures and prevent accurate code analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// Import the Python module which provides necessary classes and predicates for analyzing Python code
import python

// Define the source of syntax errors in Python code
from SyntaxError errorInstance

// Filter out encoding-related errors as they are handled differently
where not errorInstance instanceof EncodingError

// Return the syntax error along with a contextual message including the Python version
select errorInstance, errorInstance.getMessage() + " (in Python " + major_version() + ")."