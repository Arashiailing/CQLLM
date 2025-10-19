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

// Import the Python module which provides essential classes and predicates for analyzing Python source code
import python

// Query to identify syntax errors in Python code that could lead to runtime failures
// This query specifically excludes encoding-related errors as they require different handling approaches
from SyntaxError syntaxErrorInstance
where 
    // Exclude encoding errors to focus on genuine syntax issues in the code structure
    not syntaxErrorInstance instanceof EncodingError
select 
    // The syntax error instance that was detected
    syntaxErrorInstance, 
    // Detailed error message including the specific syntax issue and Python version context
    syntaxErrorInstance.getMessage() + " (in Python " + major_version() + ")."