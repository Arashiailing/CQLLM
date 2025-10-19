/**
 * @name NotImplemented is not an Exception
 * @description Detects code that raises 'NotImplemented' instead of 'NotImplementedError',
 *              causing runtime type errors since NotImplemented is not an exception class.
 * @kind problem
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raise-not-implemented
 * @tags reliability
 *       maintainability
 */

// Import core Python language analysis capabilities
import python

// Import specialized detection logic for NotImplemented misuse in exception handling
import Exceptions.NotImplemented

// Identify problematic expressions where NotImplemented is incorrectly raised
from Expr problematicExpression
where 
    // Locate raise statements that misuse NotImplemented instead of the proper exception
    use_of_not_implemented_in_raise(_, problematicExpression)
select 
    // Report the problematic expression with corrective guidance
    problematicExpression, "NotImplemented is not an Exception. Did you mean NotImplementedError?"