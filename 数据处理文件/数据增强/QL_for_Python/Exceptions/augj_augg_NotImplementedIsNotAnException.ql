/**
 * @name NotImplemented is not an Exception
 * @description Detects incorrect usage of 'NotImplemented' in raise statements.
 *              This causes runtime type errors since NotImplemented is not an exception class.
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

from Expr erroneousRaiseExpr
where 
  // Identify raise statements incorrectly using NotImplemented
  use_of_not_implemented_in_raise(_, erroneousRaiseExpr)
select 
  erroneousRaiseExpr, 
  "NotImplemented is not an Exception. Use NotImplementedError instead."