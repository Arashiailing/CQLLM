/**
 * @name NotImplemented is not an Exception
 * @description Detects raise statements that incorrectly use 'NotImplemented' 
 *              instead of 'NotImplementedError', causing type errors since 
 *              NotImplemented is not an exception class.
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

from Expr misusedNotImplementedExpr
where 
  // Identify raise statements containing incorrect NotImplemented usage
  use_of_not_implemented_in_raise(_, misusedNotImplementedExpr)
select 
  misusedNotImplementedExpr, 
  "NotImplemented is not an Exception. Did you mean NotImplementedError?"