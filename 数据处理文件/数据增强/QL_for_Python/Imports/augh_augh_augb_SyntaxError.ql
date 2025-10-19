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

// Import Python analysis module for source code examination
import python

// Identify syntax errors excluding encoding-related issues
from SyntaxError syntacticError
where 
    // Exclude encoding errors as they constitute a separate issue category
    not syntacticError instanceof EncodingError

// Generate output message containing error details and Python version context
select syntacticError, 
       // Construct message combining error description and Python version
       syntacticError.getMessage() + " (in Python " + major_version() + ")."