/**
 * @name NotImplemented is not an Exception
 * @description Identifies incorrect usage of 'NotImplemented' in raise statements
 *              where an exception type is expected. Using 'NotImplemented' instead
 *              of 'NotImplementedError' causes runtime type errors.
 * @kind problem
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raise-not-implemented
 * @tags reliability
 *       maintainability
 */

// Core Python language analysis modules
import python

// Specialized module for detecting NotImplemented exception misusage
import Exceptions.NotImplemented

// Identify raise statements incorrectly using NotImplemented
from Expr incorrectRaiseExpr
where 
    // Find raise statements that misuse NotImplemented
    use_of_not_implemented_in_raise(_, incorrectRaiseExpr)
select 
    // Report the problematic expression with remediation guidance
    incorrectRaiseExpr, "NotImplemented is not an Exception. Did you mean NotImplementedError?"