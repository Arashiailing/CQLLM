/**
 * @name NotImplemented is not an Exception
 * @description This query identifies instances where 'NotImplemented' is incorrectly used as an exception in raise statements.
 *              Using 'NotImplemented' instead of 'NotImplementedError' will result in a type error at runtime.
 * @kind problem
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raise-not-implemented
 * @tags reliability
 *       maintainability
 */

// Import necessary modules for Python code analysis
import python
import Exceptions.NotImplemented

// Identify expressions where NotImplemented is used in raise statements
from Expr notImplementedUsage
where 
    // Filter for expressions that use NotImplemented in a raise context
    use_of_not_implemented_in_raise(_, notImplementedUsage)
// Report the problematic usage with a suggested fix
select notImplementedUsage, "NotImplemented is not an Exception. Did you mean NotImplementedError?"