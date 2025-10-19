/**
 * @name Incorrect NotImplemented Exception
 * @description Identifies code that raises 'NotImplemented' instead of the proper 'NotImplementedError'.
 *              This is a type error at runtime because 'NotImplemented' is not an exception class.
 * @kind problem
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raise-not-implemented
 * @tags reliability
 *       maintainability
 */

// Import essential Python analysis libraries
import python

// Import specialized module for detecting NotImplemented misuse patterns
import Exceptions.NotImplemented

// Locate raise statements with incorrect exception usage
from Expr incorrectRaiseExpr
where 
    // Detect raise statements that use NotImplemented instead of the proper exception class
    use_of_not_implemented_in_raise(_, incorrectRaiseExpr)
select 
    // Output the problematic expression with suggested fix
    incorrectRaiseExpr, "NotImplemented is not an Exception. Did you mean NotImplementedError?"