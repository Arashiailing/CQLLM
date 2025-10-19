/**
 * @name NotImplemented is not an Exception
 * @description Identifies raise statements incorrectly using 'NotImplemented' 
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

from Expr problematicRaiseExpr
where 
  // Locate raise statements that misuse the built-in constant NotImplemented
  use_of_not_implemented_in_raise(_, problematicRaiseExpr)
select problematicRaiseExpr, "NotImplemented is not an Exception. Did you mean NotImplementedError?"