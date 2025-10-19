/**
 * @name NotImplemented is not an Exception
 * @description Detects code that raises 'NotImplemented' instead of 'NotImplementedError'.
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

// Identify problematic expressions where NotImplemented is raised
from Expr problematicExpr, string errorMessage
where 
    // Check for raise statements using NotImplemented instead of the proper exception
    use_of_not_implemented_in_raise(_, problematicExpr) and
    // Define the corrective message for detected issues
    errorMessage = "NotImplemented is not an Exception. Did you mean NotImplementedError?"
select 
    // Report the problematic expression with its associated corrective message
    problematicExpr, errorMessage