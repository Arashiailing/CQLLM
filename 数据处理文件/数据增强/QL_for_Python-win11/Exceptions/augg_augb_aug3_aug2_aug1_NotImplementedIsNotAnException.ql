/**
 * @name NotImplemented is not an Exception
 * @description Detects raise statements that incorrectly use 'NotImplemented'
 *              instead of 'NotImplementedError', causing runtime type errors.
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

from Expr misusedNotImplemented
where 
  // Identify raise statements with incorrect NotImplemented usage
  use_of_not_implemented_in_raise(_, misusedNotImplemented)
select 
  misusedNotImplemented, 
  "NotImplemented is not an Exception. Did you mean NotImplementedError?"