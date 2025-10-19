/**
 * @name NotImplemented is not an Exception
 * @description Identifies code that raises 'NotImplemented' instead of 'NotImplementedError'.
 *              This causes runtime type errors since NotImplemented is not an exception class.
 * @kind problem
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raise-not-implemented
 * @tags reliability
 *       maintainability
 */

// Fundamental Python language analysis components
import python

// Analysis module for detecting NotImplemented misuse in exception handling
import Exceptions.NotImplemented

// Find expressions where NotImplemented is incorrectly raised as an exception
from Expr incorrectNotImplementedUsage
where 
    // Detect raise statements that improperly use NotImplemented
    // instead of the correct NotImplementedError
    use_of_not_implemented_in_raise(_, incorrectNotImplementedUsage)
select 
    // Output the problematic expression with remediation guidance
    incorrectNotImplementedUsage, "NotImplemented is not an Exception. Did you mean NotImplementedError?"