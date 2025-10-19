/**
 * @name Raising NotImplemented Instead Of Exception
 * @description Identifies raise statements that incorrectly use 'NotImplemented' 
 *              instead of an exception type, causing runtime errors.
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

from Raise raiseStmt, Expr raisedExpr
where use_of_not_implemented_in_raise(raiseStmt, raisedExpr)
select raisedExpr, "NotImplemented is not an Exception. Did you mean NotImplementedError?"