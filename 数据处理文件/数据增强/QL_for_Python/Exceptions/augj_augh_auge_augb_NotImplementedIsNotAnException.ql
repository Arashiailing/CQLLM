/**
 * @name NotImplemented is not an Exception
 * @description Identifies incorrect usage of 'NotImplemented' in raise statements,
 *              which leads to runtime type errors due to NotImplemented not being an exception type.
 * @kind problem
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raise-not-implemented
 * @tags reliability
 *       maintainability
 */

// Import core Python analysis framework
import python

// Import specialized module for NotImplemented exception detection
import Exceptions.NotImplemented

// Identify problematic expressions where NotImplemented is misused in raise contexts
from Expr problematicExpr
// Filter expressions to find cases where NotImplemented is incorrectly raised
where use_of_not_implemented_in_raise(_, problematicExpr)
// Report findings with corrective guidance message
select problematicExpr, "NotImplemented is not an Exception. Did you mean NotImplementedError?"