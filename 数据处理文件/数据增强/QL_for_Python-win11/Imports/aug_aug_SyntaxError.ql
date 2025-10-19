/**
 * @name Python Syntax Error Detection
 * @description Identifies Python code with syntax errors that cause runtime failures and hinder code analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// Import the Python module which provides classes and predicates for analyzing Python code
import python

// Find all syntax errors in the codebase, excluding those related to encoding issues
from SyntaxError syntaxError
where not syntaxError instanceof EncodingError
// Return the syntax error instance along with a detailed error message including the Python version
select syntaxError, syntaxError.getMessage() + " (in Python " + major_version() + ")."