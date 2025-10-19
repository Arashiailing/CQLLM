/**
 * @name NotImplemented is not an Exception
 * @description Detects raise statements that incorrectly use 'NotImplemented',
 *              which leads to type errors since NotImplemented is not an exception class.
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

from Expr notImplementedInRaise
where 
  // Find raise statements that misuse NotImplemented
  use_of_not_implemented_in_raise(_, notImplementedInRaise)
select 
  notImplementedInRaise, 
  "NotImplemented is not an Exception. Did you mean NotImplementedError?"