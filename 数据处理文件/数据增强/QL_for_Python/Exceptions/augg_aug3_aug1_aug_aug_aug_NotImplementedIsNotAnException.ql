/**
 * @name NotImplemented is not an Exception
 * @description Identifies code that raises 'NotImplemented' instead of 'NotImplementedError',
 *              leading to runtime type errors since NotImplemented is not an exception class.
 * @kind problem
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raise-not-implemented
 * @tags reliability
 *       maintainability
 */

// Core Python language analysis components
import python

// Specialized module for detecting NotImplemented misuse in exception contexts
import Exceptions.NotImplemented

// Identify expressions where NotImplemented is incorrectly used in raise statements
from Expr misusedNotImplementedExpr
where 
    // Detect raise statements using NotImplemented instead of the proper exception class
    use_of_not_implemented_in_raise(_, misusedNotImplementedExpr)
select 
    // Report the problematic expression with corrective guidance
    misusedNotImplementedExpr, "NotImplemented is not an Exception. Did you mean NotImplementedError?"