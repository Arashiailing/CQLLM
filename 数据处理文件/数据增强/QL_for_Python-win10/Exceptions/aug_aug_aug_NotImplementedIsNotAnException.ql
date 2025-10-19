/**
 * @name NotImplemented is not an Exception
 * @description Detects incorrect usage of 'NotImplemented' where an exception is expected.
 *              Raising 'NotImplemented' instead of 'NotImplementedError' leads to runtime type errors.
 * @kind problem
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raise-not-implemented
 * @tags reliability
 *       maintainability
 */

// Core Python analysis modules
import python

// Specialized analysis module for NotImplemented exception handling
import Exceptions.NotImplemented

// Identify problematic raise statements using NotImplemented instead of NotImplementedError
from Expr problematicRaiseExpr
where 
    // Locate raise statements incorrectly using NotImplemented
    use_of_not_implemented_in_raise(_, problematicRaiseExpr)
select 
    // Report the problematic expression with corrective suggestion
    problematicRaiseExpr, "NotImplemented is not an Exception. Did you mean NotImplementedError?"