/**
 * @name NotImplemented is not an Exception
 * @description Detects when 'NotImplemented' is incorrectly used as an exception in raise statements.
 *              This causes a type error since NotImplemented is not an exception class.
 * @kind problem
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raise-not-implemented
 * @tags reliability
 *       maintainability
 */

import python
import Exceptions.NotImplemented

// Identify expressions where NotImplemented is used in raise statements
from Expr notImplementedExpr
// Filter cases where NotImplemented appears in raise contexts
where use_of_not_implemented_in_raise(_, notImplementedExpr)
// Report the problematic expression with remediation guidance
select notImplementedExpr, "NotImplemented is not an Exception. Use NotImplementedError instead."