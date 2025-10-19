/**
 * @name NotImplemented is not an Exception
 * @description Detects usage of 'NotImplemented' where an exception is expected.
 *              This will cause a runtime type error since NotImplemented is not an exception class.
 * @kind problem
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raise-not-implemented
 * @tags reliability
 *       maintainability
 */

// Import core Python analysis module
import python

// Import module for NotImplemented exception detection
import Exceptions.NotImplemented

// Identify expressions using NotImplemented in raise statements
from Expr problematicExpr
// Filter expressions where NotImplemented is incorrectly used in exception handling
where use_of_not_implemented_in_raise(_, problematicExpr)
// Output problematic expressions with remediation guidance
select problematicExpr, "NotImplemented is not an Exception. Did you mean NotImplementedError?"