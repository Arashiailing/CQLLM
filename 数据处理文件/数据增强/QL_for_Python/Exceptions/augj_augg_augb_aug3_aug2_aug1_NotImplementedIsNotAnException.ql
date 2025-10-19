/**
 * @name NotImplemented is not an Exception
 * @description Identifies raise statements that incorrectly use 'NotImplemented'
 *              instead of 'NotImplementedError', which leads to runtime type errors.
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

from Expr incorrectNotImplementedUsage
where 
  // Find raise statements that misuse NotImplemented instead of NotImplementedError
  use_of_not_implemented_in_raise(_, incorrectNotImplementedUsage)
select 
  incorrectNotImplementedUsage, 
  "NotImplemented is not an Exception. Did you mean NotImplementedError?"