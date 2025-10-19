/**
 * @name Python Syntax Error Detection
 * @description This query identifies Python syntax errors that may lead to runtime failures
 *              and hinder proper code analysis. The analysis specifically excludes 
 *              encoding-related errors to concentrate on fundamental syntax problems.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// Import necessary module for Python source code analysis
import python

// Identify syntax error instances while excluding encoding-related issues
from SyntaxError syntaxIssue
where not syntaxIssue instanceof EncodingError
// Format and output the syntax error with its description and Python version
select syntaxIssue, 
       syntaxIssue.getMessage() + " (in Python " + major_version() + ")."