/**
 * @name Syntax error
 * @description Finds syntax errors in Python code that result in runtime failures and prevent proper analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// Import necessary Python library for code querying and analysis
import python

// Query for syntax errors, excluding encoding-related issues
from SyntaxError syntaxIssue
where not syntaxIssue instanceof EncodingError
select syntaxIssue, syntaxIssue.getMessage() + " (in Python " + major_version() + ")."
// Return the syntax error instance along with a detailed error message including Python version