/**
 * @name Syntax error
 * @description Detects syntax errors in Python code that lead to runtime failures and hinder code analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// Import Python language analysis module for syntax error detection
import python

// Identify syntax errors excluding encoding-related issues
from SyntaxError syntaxError
where 
    // Filter out encoding errors to focus on pure syntax problems
    not (syntaxError instanceof EncodingError)
// Output syntax error details with Python version context
select 
    syntaxError, 
    // Generate error message including description and Python version
    syntaxError.getMessage() + " (in Python " + major_version() + ")."