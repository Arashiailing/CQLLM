/**
 * @name Syntax error detection
 * @description Detects syntax errors causing runtime failures and impeding code analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// Import the Python module for code analysis capabilities
import python

// Find syntax issues that are not related to encoding problems
from SyntaxError syntaxFault
where not syntaxFault instanceof EncodingError

// Create result with error message and Python version information
select syntaxFault, 
       // Format output to include error details and Python version
       syntaxFault.getMessage() + " (in Python " + major_version() + ")."