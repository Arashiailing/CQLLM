/**
 * @name NotImplemented is not an Exception
 * @description Identifies incorrect usage of 'NotImplemented' in raise statements.
 *              This causes a type error because NotImplemented is not an exception class.
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

from Expr badNotImplementedUsage
where 
  // Check for NotImplemented usage in raise contexts
  use_of_not_implemented_in_raise(_, badNotImplementedUsage)
select badNotImplementedUsage, "NotImplemented is not an Exception. Did you mean NotImplementedError?"