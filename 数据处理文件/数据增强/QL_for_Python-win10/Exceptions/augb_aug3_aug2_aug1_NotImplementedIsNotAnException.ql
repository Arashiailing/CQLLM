/**
 * @name NotImplemented is not an Exception
 * @description Identifies raise statements incorrectly using 'NotImplemented',
 *              which causes type errors since NotImplemented is not an exception class.
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

from Expr erroneousNotImplemented
where 
  // Locate raise statements misusing NotImplemented
  use_of_not_implemented_in_raise(_, erroneousNotImplemented)
select 
  erroneousNotImplemented, 
  "NotImplemented is not an Exception. Did you mean NotImplementedError?"