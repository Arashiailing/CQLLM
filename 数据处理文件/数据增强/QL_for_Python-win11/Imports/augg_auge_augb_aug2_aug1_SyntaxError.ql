/**
 * @name Syntax error
 * @description Detects syntax errors in Python code that lead to runtime failures and hinder code analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// Import the Python language analysis module to enable syntax error detection capabilities
import python

// Identify all syntax errors that are not related to encoding issues
from SyntaxError syntaxIssue
where 
    // Exclude encoding errors to focus purely on syntax problems
    not syntaxIssue instanceof EncodingError
// Output the syntax error along with its description and the current Python major version
select 
    syntaxIssue, 
    // Construct a message containing error details and Python version information
    syntaxIssue.getMessage() + " (in Python " + major_version() + ")."