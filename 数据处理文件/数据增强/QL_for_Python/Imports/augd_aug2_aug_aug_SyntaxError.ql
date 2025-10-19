/**
 * @name Python Syntax Error Detection
 * @description Identifies Python syntax errors that could cause runtime failures and hinder static analysis
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// Core Python analysis module import
import python

// Primary query targeting syntax errors while excluding encoding-related issues
from SyntaxError syntaxError
where not syntaxError instanceof EncodingError
// Construct detailed error message with Python version context
select syntaxError, syntaxError.getMessage() + " (in Python " + major_version() + ")."