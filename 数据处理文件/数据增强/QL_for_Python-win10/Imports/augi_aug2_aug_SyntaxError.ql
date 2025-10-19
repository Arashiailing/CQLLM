/**
 * @name Syntax error
 * @description Detects Python syntax errors that lead to runtime failures and hinder effective code analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// Import the necessary Python module for performing code analysis and querying
import python

// Identify syntax errors in Python code
from SyntaxError syntaxIssue
// Filter out encoding-related errors
where not syntaxIssue instanceof EncodingError
// Return the syntax error instance with a detailed message including Python version
select syntaxIssue, syntaxIssue.getMessage() + " (in Python " + major_version() + ")."