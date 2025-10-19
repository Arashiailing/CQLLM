/**
 * @name NotImplemented is not an Exception
 * @description Detects code that raises 'NotImplemented' instead of 'NotImplementedError'.
 *              This leads to runtime type errors since NotImplemented is not an exception class.
 * @kind problem
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raise-not-implemented
 * @tags reliability
 *       maintainability
 */

// Import necessary modules for Python code analysis
import python

// Import specialized module for detecting NotImplemented misuse in exception handling
import Exceptions.NotImplemented

// Query to detect incorrect usage of NotImplemented in raise statements
from Expr problematicExpr
where 
    // Check for raise statements that incorrectly use NotImplemented
    // instead of the proper exception class NotImplementedError
    use_of_not_implemented_in_raise(_, problematicExpr)
select 
    // Report the problematic expression with guidance for remediation
    problematicExpr, "NotImplemented is not an Exception. Did you mean NotImplementedError?"