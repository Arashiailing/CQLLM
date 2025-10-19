/**
 * @name NotImplemented is not an Exception
 * @description Identifies instances where 'NotImplemented' is mistakenly used as an exception in raise statements.
 *              This pattern leads to a type error because NotImplemented is not an exception class.
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

// Identify expressions where NotImplemented is incorrectly used in raise statements
from Expr problematicNotImplementedExpr
where 
  use_of_not_implemented_in_raise(_, problematicNotImplementedExpr)

// Report the issue with a helpful message
select 
  problematicNotImplementedExpr, 
  "NotImplemented is not an Exception. Did you mean NotImplementedError?"