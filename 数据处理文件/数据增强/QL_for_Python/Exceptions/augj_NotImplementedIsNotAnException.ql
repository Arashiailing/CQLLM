/**
 * @name NotImplemented is not an Exception
 * @description Raising 'NotImplemented' instead of 'NotImplementedError' causes type errors.
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

from Expr notImplementedExpr
where use_of_not_implemented_in_raise(_, notImplementedExpr)
select notImplementedExpr, 
  "NotImplemented is not an Exception. Replace with NotImplementedError to avoid type errors."