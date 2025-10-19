/**
 * @name Syntax error
 * @description Identifies Python syntax errors that cause runtime failures and impede proper code analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// Import required Python module for code querying and analysis tasks
import python

// Query for syntax errors, excluding encoding-related issues
from SyntaxError syntaxFault
where not syntaxFault instanceof EncodingError
select syntaxFault, syntaxFault.getMessage() + " (in Python " + major_version() + ")."
// Return the syntax error instance along with a detailed error message including Python version