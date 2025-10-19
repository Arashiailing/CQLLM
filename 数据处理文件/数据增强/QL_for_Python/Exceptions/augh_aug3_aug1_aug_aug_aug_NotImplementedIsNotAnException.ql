/**
 * @name NotImplemented is not an Exception
 * @description Identifies code that raises 'NotImplemented' rather than 'NotImplementedError',
 *              which leads to runtime type errors because NotImplemented is not an exception class.
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

// Import specialized functionality for detecting NotImplemented misuse in exception handling
import Exceptions.NotImplemented

// Find expressions where NotImplemented is incorrectly used in raise statements
from Expr incorrectNotImplementedUsage
where 
    // Identify raise statements that utilize NotImplemented instead of the correct NotImplementedError
    use_of_not_implemented_in_raise(_, incorrectNotImplementedUsage)
select 
    // Report the problematic expression along with guidance for correction
    incorrectNotImplementedUsage, "NotImplemented is not an Exception. Did you mean NotImplementedError?"