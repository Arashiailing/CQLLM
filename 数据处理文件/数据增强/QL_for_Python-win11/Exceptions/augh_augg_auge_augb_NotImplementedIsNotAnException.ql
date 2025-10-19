/**
 * @name NotImplemented is not an Exception
 * @description Detects improper usage of 'NotImplemented' in raise statements,
 *              which causes runtime type errors instead of proper exception handling.
 * @kind problem
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raise-not-implemented
 * @tags reliability
 *       maintainability
 */

// Import core Python analysis framework
import python

// Import specialized module for NotImplemented exception analysis
import Exceptions.NotImplemented

// Identify expressions where NotImplemented is misused in raise contexts
from Expr misusedNotImplementedExpr
// Filter expressions that violate proper exception handling
where 
    // Verify expression represents incorrect NotImplemented usage in raise statements
    use_of_not_implemented_in_raise(_, misusedNotImplementedExpr)
// Report the violation with corrective guidance
select misusedNotImplementedExpr, "NotImplemented is not an Exception. Did you mean NotImplementedError?"