/**
 * @name NotImplemented is not an Exception
 * @description Identifies instances where 'NotImplemented' is incorrectly used in raise statements.
 *              This leads to type errors because NotImplemented is a constant, not an exception class.
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

from Expr problematicNotImplementedExpr
where 
  // Detect raise statements that misuse NotImplemented (which is not an exception)
  use_of_not_implemented_in_raise(_, problematicNotImplementedExpr)
select 
  problematicNotImplementedExpr, 
  "NotImplemented is not an Exception. Did you mean NotImplementedError?"