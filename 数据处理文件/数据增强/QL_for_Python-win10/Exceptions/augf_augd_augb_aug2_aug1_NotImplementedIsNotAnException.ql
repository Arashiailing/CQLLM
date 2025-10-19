/**
 * @name NotImplemented is not an Exception
 * @description Detects incorrect usage of 'NotImplemented' in raise statements.
 *              This pattern causes a type error because NotImplemented is not an exception class.
 *              The correct exception class to use is NotImplementedError.
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

// Define a variable to capture expressions where NotImplemented is incorrectly used in raise statements
from Expr erroneousNotImplementedUsage
where 
  // Identify instances where NotImplemented appears in a raise statement context
  use_of_not_implemented_in_raise(_, erroneousNotImplementedUsage)
select erroneousNotImplementedUsage, "NotImplemented is not an Exception. Did you mean NotImplementedError?"