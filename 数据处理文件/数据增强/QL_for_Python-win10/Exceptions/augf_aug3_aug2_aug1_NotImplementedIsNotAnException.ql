/**
 * @name NotImplemented is not an Exception
 * @description Identifies improper usage of 'NotImplemented' in raise statements,
 *              which causes runtime errors since NotImplemented is not an exception class.
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
where 
  // Detect raise statements using NotImplemented incorrectly
  use_of_not_implemented_in_raise(_, notImplementedExpr)
select 
  notImplementedExpr, 
  "NotImplemented is not an Exception. Did you mean NotImplementedError?"