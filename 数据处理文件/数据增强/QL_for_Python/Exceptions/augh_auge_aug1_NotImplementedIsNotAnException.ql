/**
 * @name NotImplemented is not an Exception
 * @description Detects improper use of 'NotImplemented' in raise statements.
 *              This causes type errors since NotImplemented is not an exception class.
 *              The correct exception class should be NotImplementedError.
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

// Identify expressions where NotImplemented is misused in raise contexts
from Expr problematicExpr
where 
  // Check for problematic usage patterns in raise statements
  use_of_not_implemented_in_raise(_, problematicExpr)
select 
  problematicExpr, 
  "NotImplemented is not an Exception. Did you mean NotImplementedError?"