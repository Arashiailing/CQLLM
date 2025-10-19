/**
 * @name Python Syntax Error Detection
 * @description Identifies syntax errors in Python source code that may lead to runtime
 *              exceptions and impede static analysis capabilities. This analysis
 *              specifically filters out encoding-related issues to concentrate on
 *              genuine syntax problems.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// Import the Python analysis module for code examination
import python

// Find syntax issues that are not encoding-related problems
from SyntaxError syntaxIssue
where 
  // Exclude encoding errors from our analysis
  not syntaxIssue instanceof EncodingError
select 
  syntaxIssue, 
  syntaxIssue.getMessage() + " (in Python " + major_version() + ")."
// Report the syntax error along with its message and the current Python major version