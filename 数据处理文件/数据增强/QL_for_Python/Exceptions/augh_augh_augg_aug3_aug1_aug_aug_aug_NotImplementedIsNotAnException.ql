/**
 * @name NotImplemented is not an Exception
 * @description Detects code that raises 'NotImplemented' instead of 'NotImplementedError',
 *              which causes runtime type errors because NotImplemented is not an exception class.
 * @kind problem
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raise-not-implemented
 * @tags reliability
 *       maintainability
 */

// Import fundamental Python language analysis capabilities
import python

// Import specialized detection logic for NotImplemented misuse in exception handling
import Exceptions.NotImplemented

// Identify problematic expressions where NotImplemented is incorrectly used in raise contexts
from Expr problematicExpr
where 
    // Detect raise statements that mistakenly use NotImplemented
    // instead of the proper exception class
    use_of_not_implemented_in_raise(_, problematicExpr)
select 
    // Report the problematic expression with suggested correction
    problematicExpr, "NotImplemented is not an Exception. Did you mean NotImplementedError?"