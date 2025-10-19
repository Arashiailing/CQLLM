/**
 * @name NotImplemented is not an Exception
 * @description Detects raise statements using 'NotImplemented' instead of 'NotImplementedError', 
 *              which causes runtime type errors since NotImplemented is not an exception type.
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

// Import specialized module for NotImplemented misuse detection
import Exceptions.NotImplemented

// Identify problematic expressions in raise contexts
from Expr problematicExpr
// Filter expressions where NotImplemented is incorrectly used in raise statements
where use_of_not_implemented_in_raise(_, problematicExpr)
// Report findings with corrective guidance
select problematicExpr, "NotImplemented is not an Exception. Did you mean NotImplementedError?"