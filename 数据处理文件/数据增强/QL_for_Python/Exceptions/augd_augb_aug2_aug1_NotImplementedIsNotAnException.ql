/**
 * @name NotImplemented is not an Exception
 * @description Identifies incorrect usage of 'NotImplemented' in raise statements.
 *              This pattern causes a type error because NotImplemented is not an exception class.
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
  // Detects when NotImplemented is used in raise statements
  use_of_not_implemented_in_raise(_, notImplementedInRaise)
select notImplementedInRaise, "NotImplemented is not an Exception. Did you mean NotImplementedError?"