/**
 * @name NotImplemented is not an Exception
 * @description Detects code that raises 'NotImplemented' instead of 'NotImplementedError',
 *              which causes runtime type errors since NotImplemented is not an exception class.
 * @kind problem
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raise-not-implemented
 * @tags reliability
 *       maintainability
 */

// Core Python language analysis modules
import python

// Specialized analysis for NotImplemented misuse detection
import Exceptions.NotImplemented

// Identify raise statements incorrectly using NotImplemented
from Expr incorrectRaiseExpr
where 
    // Match raise statements using NotImplemented instead of NotImplementedError
    use_of_not_implemented_in_raise(_, incorrectRaiseExpr)
select 
    // Report the problematic expression with remediation advice
    incorrectRaiseExpr, "NotImplemented is not an Exception. Did you mean NotImplementedError?"