/**
 * @name NotImplemented is not an Exception
 * @description Detects improper use of 'NotImplemented' in raise statements.
 *              This causes type errors since NotImplemented is not an exception class.
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

from Expr problematicExpr, Raise raiseStatement
where use_of_not_implemented_in_raise(raiseStatement, problematicExpr)
select problematicExpr, "NotImplemented is not an Exception. Did you mean NotImplementedError?"