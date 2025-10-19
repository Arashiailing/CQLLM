/**
 * @name Syntax error
 * @description Identifies Python syntax errors that cause runtime failures and hinder thorough code analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// Import the Python analysis module for code querying capabilities and syntax error identification
import python

// Define the source of syntax errors in Python code
from SyntaxError syntaxError

// Filter conditions to identify relevant syntax issues
where 
  // Exclude encoding-related errors to focus on genuine syntax problems
  not syntaxError instanceof EncodingError

// Output the identified syntax errors with contextual information
select 
  syntaxError, 
  // Format the error message to include Python version information
  syntaxError.getMessage() + " (in Python " + major_version() + ")."