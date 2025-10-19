/**
 * @name NotImplemented is not an Exception
 * @description Identifies code that raises 'NotImplemented' instead of 'NotImplementedError',
 *              leading to runtime type errors because NotImplemented is not an exception class.
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

// Import specialized module for detecting NotImplemented misuse in exception handling
import Exceptions.NotImplemented

// Find expressions where NotImplemented is improperly used in raise statements
from Expr incorrectNotImplementedUsage
where 
    // Detect raise statements that utilize NotImplemented instead of the correct NotImplementedError
    exists(Stmt parent |
        use_of_not_implemented_in_raise(parent, incorrectNotImplementedUsage)
    )
select 
    // Present the problematic expression with recommended fix
    incorrectNotImplementedUsage, "NotImplemented is not an Exception. Did you mean NotImplementedError?"