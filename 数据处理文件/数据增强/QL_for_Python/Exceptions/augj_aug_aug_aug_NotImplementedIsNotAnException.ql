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

// Import core Python analysis capabilities
import python

// Import specialized module for detecting NotImplemented misuse in exception handling
import Exceptions.NotImplemented

// Define the source of our analysis: expressions in raise statements
from Expr incorrectRaiseStatement

// Filter for raise statements that incorrectly use NotImplemented
where 
    // This predicate identifies cases where NotImplemented is used in a raise context
    use_of_not_implemented_in_raise(_, incorrectRaiseStatement)

// Output the problematic expression with guidance for correction
select 
    incorrectRaiseStatement, 
    "NotImplemented is not an Exception. Did you mean NotImplementedError?"