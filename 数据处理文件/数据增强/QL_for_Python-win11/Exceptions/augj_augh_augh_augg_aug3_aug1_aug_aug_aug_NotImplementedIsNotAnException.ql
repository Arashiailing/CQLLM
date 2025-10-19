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

// Identify expressions where NotImplemented is incorrectly used in raise contexts
from Expr faultyNotImplementedUsage
where 
    // The expression is part of a raise statement
    // and incorrectly uses NotImplemented instead of the proper exception class
    use_of_not_implemented_in_raise(_, faultyNotImplementedUsage)
select 
    // Report the problematic expression with a suggested correction
    faultyNotImplementedUsage, 
    "NotImplemented is not an Exception. " + 
    "Did you mean to raise NotImplementedError instead?"