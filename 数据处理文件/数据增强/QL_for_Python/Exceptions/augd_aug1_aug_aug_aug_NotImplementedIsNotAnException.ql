/**
 * @name NotImplemented is not an Exception
 * @description Detects code that raises 'NotImplemented' instead of 'NotImplementedError'.
 *              This leads to runtime type errors since NotImplemented is not an exception class.
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

// Module for detecting NotImplemented misuse in exception handling
import Exceptions.NotImplemented

// Identify expressions where NotImplemented is incorrectly raised as an exception
from Expr misusedNotImplemented
where 
    // Locate raise statements that improperly use NotImplemented
    // instead of the correct exception class NotImplementedError
    use_of_not_implemented_in_raise(_, misusedNotImplemented)
select 
    // Report the problematic expression with remediation guidance
    misusedNotImplemented, "NotImplemented is not an Exception. Did you mean NotImplementedError?"