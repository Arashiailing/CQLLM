/**
 * @name Python syntax error detection
 * @description Identifies syntax errors in Python code that can cause runtime failures
 *              and prevent proper code analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// Import Python analysis module for syntax error detection capabilities
import python

// Identify all syntax errors excluding encoding-related issues
from SyntaxError syntaxErr
where 
    // Filter out encoding errors to focus on genuine syntax problems
    not syntaxErr instanceof EncodingError
// Return syntax error details with current Python major version information
select syntaxErr, 
       syntaxErr.getMessage() + " (in Python " + major_version() + ")."