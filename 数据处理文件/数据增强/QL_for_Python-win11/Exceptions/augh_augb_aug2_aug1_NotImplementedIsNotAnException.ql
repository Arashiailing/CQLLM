/**
 * @name NotImplemented is not an Exception
 * @description Identifies problematic usage of 'NotImplemented' in raise statements.
 *              This pattern causes runtime type errors since NotImplemented is not
 *              an exception class. The query suggests using NotImplementedError instead.
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

from Expr erroneousNotImplementedUsage
where 
  exists(Expr problematicExpr | 
    use_of_not_implemented_in_raise(_, problematicExpr) and 
    problematicExpr = erroneousNotImplementedUsage
  )
select erroneousNotImplementedUsage, "NotImplemented is not an Exception. Did you mean NotImplementedError?"