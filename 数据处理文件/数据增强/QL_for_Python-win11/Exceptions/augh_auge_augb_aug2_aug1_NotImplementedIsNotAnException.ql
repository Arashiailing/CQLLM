/**
 * @name NotImplemented is not an Exception
 * @description Detects improper use of 'NotImplemented' in raise statements.
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

from Expr incorrectNotImplementedRaise
where 
  // Identify raise statements using NotImplemented instead of NotImplementedError
  use_of_not_implemented_in_raise(_, incorrectNotImplementedRaise)
select incorrectNotImplementedRaise, "NotImplemented is not an Exception. Did you mean NotImplementedError?"