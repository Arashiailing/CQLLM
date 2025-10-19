/**
 * @name Syntax Error Detection
 * @description Identifies Python syntax errors that cause runtime failures and impede code analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// Import the Python language analysis module for detecting syntax issues
import python

// Find syntax errors while excluding encoding-related problems
from SyntaxError syntaxIssue
where 
    // Exclude encoding errors to focus on genuine syntax issues
    not (syntaxIssue instanceof EncodingError)
// Report syntax error information along with Python version details
select 
    syntaxIssue, 
    // Construct an error message containing the description and Python version
    syntaxIssue.getMessage() + " (in Python " + major_version() + ")."