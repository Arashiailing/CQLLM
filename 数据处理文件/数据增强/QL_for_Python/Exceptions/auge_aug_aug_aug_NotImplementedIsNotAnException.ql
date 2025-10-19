/**
 * @name NotImplemented is not an Exception
 * @description Identifies incorrect usage of 'NotImplemented' in raise statements where an exception is expected.
 *              Using 'NotImplemented' instead of 'NotImplementedError' causes runtime type errors.
 * @kind problem
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raise-not-implemented
 * @tags reliability
 *       maintainability
 */

// Core Python analysis modules
import python

// Specialized analysis module for NotImplemented exception handling
import Exceptions.NotImplemented

// Identify raise statements that incorrectly use NotImplemented instead of NotImplementedError
from Expr erroneousRaiseStatement
where 
    // Locate raise statements incorrectly using NotImplemented
    use_of_not_implemented_in_raise(_, erroneousRaiseStatement)
select 
    // Report the problematic statement with a corrective suggestion
    erroneousRaiseStatement, 
    "NotImplemented is not an Exception. Replace with NotImplementedError to avoid runtime type errors."