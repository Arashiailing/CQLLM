/**
 * @name Syntax error
 * @description Detects Python syntax errors that lead to runtime failures and hinder proper code analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// Import the Python module which provides the necessary classes and predicates for analyzing Python code
import python

// Query for syntax defects, excluding encoding-related issues
// The result will include the syntax defect instance and a detailed error message with Python version
from SyntaxError syntaxDefect
where not syntaxDefect instanceof EncodingError
select syntaxDefect, syntaxDefect.getMessage() + " (in Python " + major_version() + ")."