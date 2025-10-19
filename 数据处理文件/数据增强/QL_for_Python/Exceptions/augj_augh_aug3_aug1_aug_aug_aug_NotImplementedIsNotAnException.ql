/**
 * @name NotImplemented is not an Exception
 * @description Identifies code that raises 'NotImplemented' instead of 'NotImplementedError'.
 *              This leads to runtime type errors because NotImplemented is not an exception class.
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

// Import specialized detection for NotImplemented misuse in exception handling
import Exceptions.NotImplemented

// Identify problematic expressions where NotImplemented is incorrectly raised
from Expr problematicExpr
where 
    // Detect raise statements using NotImplemented instead of NotImplementedError
    use_of_not_implemented_in_raise(_, problematicExpr)
select 
    // Report the problematic expression with corrective guidance
    problematicExpr, "NotImplemented is not an Exception. Did you mean NotImplementedError?"