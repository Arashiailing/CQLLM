/**
 * @name NotImplemented is not an Exception
 * @description Identifies code that raises 'NotImplemented' instead of 'NotImplementedError',
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

// Specialized analysis for detecting NotImplemented misuse
import Exceptions.NotImplemented

// Identify problematic raise statements using NotImplemented
from Expr problematicRaiseExpr
where 
    // Match raise statements incorrectly using NotImplemented
    use_of_not_implemented_in_raise(_, problematicRaiseExpr)
select 
    // Report the problematic expression with remediation guidance
    problematicRaiseExpr, "NotImplemented is not an Exception. Did you mean NotImplementedError?"