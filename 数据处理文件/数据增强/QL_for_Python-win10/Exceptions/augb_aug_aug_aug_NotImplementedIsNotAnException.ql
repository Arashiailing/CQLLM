/**
 * @name NotImplemented is not an Exception
 * @description Identifies code that raises 'NotImplemented' instead of 'NotImplementedError'.
 *              This causes runtime type errors because 'NotImplemented' is not an exception class.
 * @kind problem
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raise-not-implemented
 * @tags reliability
 *       maintainability
 */

// Import core Python analysis capabilities
import python

// Import specialized analysis for NotImplemented misuse detection
import Exceptions.NotImplemented

// Identify raise statements that incorrectly use NotImplemented
from Expr misusedNotImplementedExpr
where 
    // Detect raise statements using NotImplemented instead of the proper exception class
    use_of_not_implemented_in_raise(_, misusedNotImplementedExpr)
select 
    // Report the problematic expression with a corrective suggestion
    misusedNotImplementedExpr, "NotImplemented is not an Exception. Did you mean NotImplementedError?"