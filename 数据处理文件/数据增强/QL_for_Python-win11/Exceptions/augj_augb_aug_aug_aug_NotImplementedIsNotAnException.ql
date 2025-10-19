/**
 * @name NotImplemented is not an Exception
 * @description Detects instances where 'NotImplemented' is raised instead of 'NotImplementedError'.
 *              Raising 'NotImplemented' leads to runtime type issues since it's not an exception class.
 * @kind problem
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raise-not-implemented
 * @tags reliability
 *       maintainability
 */

// Import fundamental Python analysis functionalities
import python

// Import specific analysis module for detecting improper use of NotImplemented
import Exceptions.NotImplemented

// Find expressions where NotImplemented is incorrectly used in raise statements
from Expr incorrectNotImplementedUsage
where 
    // Identify raise statements that incorrectly utilize NotImplemented
    // instead of the proper exception class (NotImplementedError)
    use_of_not_implemented_in_raise(_, incorrectNotImplementedUsage)
select 
    // Output the problematic expression along with a recommended fix
    incorrectNotImplementedUsage, "NotImplemented is not an Exception. Did you mean NotImplementedError?"