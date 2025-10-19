/**
 * @name NotImplemented is not an Exception
 * @description Identifies incorrect usage of 'NotImplemented' in raise statements,
 *              which leads to runtime type errors since NotImplemented is not an exception type.
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

// Define the problematic expression variable with a more descriptive name
from Expr misusedNotImplementedExpr
// Filter expressions to identify NotImplemented misuse in raise contexts
where use_of_not_implemented_in_raise(_, misusedNotImplementedExpr)
// Output the problematic expression with corrective guidance
select misusedNotImplementedExpr, "NotImplemented is not an Exception. Did you mean NotImplementedError?"