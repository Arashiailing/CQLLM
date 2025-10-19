/**
 * @name NotImplemented is not an Exception
 * @description Identifies incorrect usage of 'NotImplemented' in raise statements,
 *              which causes type errors as NotImplemented is not an exception class.
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

from Expr notImplementedExpr, Raise raiseStmt
where use_of_not_implemented_in_raise(raiseStmt, notImplementedExpr)
select notImplementedExpr, "NotImplemented is not an Exception. Did you mean NotImplementedError?"