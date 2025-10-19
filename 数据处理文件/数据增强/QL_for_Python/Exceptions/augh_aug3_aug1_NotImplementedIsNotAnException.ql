/**
 * @name Raising NotImplemented Instead Of Exception
 * @description Detects incorrect use of 'NotImplemented' in raise statements,
 *              which causes runtime errors since NotImplemented is not an exception type.
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

from Raise problematicRaise, Expr nonExceptionExpr
where use_of_not_implemented_in_raise(problematicRaise, nonExceptionExpr)
select nonExceptionExpr, "NotImplemented is not an Exception. Did you mean NotImplementedError?"