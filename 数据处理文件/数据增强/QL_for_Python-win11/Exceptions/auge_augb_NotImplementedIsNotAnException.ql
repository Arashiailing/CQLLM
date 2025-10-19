/**
 * @name NotImplemented is not an Exception
 * @description Detects incorrect usage of 'NotImplemented' as an exception in raise statements,
 *              which will cause a type error at runtime.
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

// Identify expressions where NotImplemented is incorrectly used in raise contexts
from Expr problematicExpr
// Filter expressions to locate NotImplemented misuse in raise statements
where use_of_not_implemented_in_raise(_, problematicExpr)
// Output the problematic expression with corrective suggestion
select problematicExpr, "NotImplemented is not an Exception. Did you mean NotImplementedError?"