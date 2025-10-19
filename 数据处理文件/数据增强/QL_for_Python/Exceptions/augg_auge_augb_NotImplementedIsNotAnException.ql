/**
 * @name NotImplemented is not an Exception
 * @description Identifies improper use of 'NotImplemented' in raise statements,
 *              which leads to runtime type errors instead of proper exception handling.
 * @kind problem
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raise-not-implemented
 * @tags reliability
 *       maintainability
 */

// Import Python analysis framework
import python

// Import module for NotImplemented exception handling
import Exceptions.NotImplemented

// Define the source of our analysis: expressions that incorrectly use NotImplemented
from Expr faultyRaiseExpr
// Apply filter to identify expressions where NotImplemented is used in raise contexts
where 
    // Check if the expression represents a misuse of NotImplemented in raise statements
    use_of_not_implemented_in_raise(_, faultyRaiseExpr)
// Report the identified issue with a corrective message
select faultyRaiseExpr, "NotImplemented is not an Exception. Did you mean NotImplementedError?"