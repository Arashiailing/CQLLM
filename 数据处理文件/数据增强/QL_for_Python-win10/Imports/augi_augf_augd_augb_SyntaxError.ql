/**
 * @name Syntax error detection
 * @description Identifies Python syntax errors that may cause runtime failures and obstruct static analysis
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// Import core Python analysis capabilities
import python

// Define a variable to hold syntax error instances, excluding encoding-related problems
from SyntaxError syntaxIssue
where 
  // Exclude encoding-specific errors from our analysis
  not syntaxIssue instanceof EncodingError
select 
  syntaxIssue, 
  // Generate detailed error message including Python version information
  syntaxIssue.getMessage() + " (detected in Python " + major_version() + ")."