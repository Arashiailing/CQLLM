/**
 * @name Python Syntax Error Detection
 * @description Identifies Python code segments that contain syntax errors, which could cause runtime failures
 *              and hinder proper code analysis and understanding
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error */

import python

// Identify syntax issues in Python code, excluding those related to character encoding
from SyntaxError syntaxIssue
where not syntaxIssue instanceof EncodingError
// Return detailed error message along with the relevant Python version information
select syntaxIssue, syntaxIssue.getMessage() + " (in Python " + major_version() + ")."