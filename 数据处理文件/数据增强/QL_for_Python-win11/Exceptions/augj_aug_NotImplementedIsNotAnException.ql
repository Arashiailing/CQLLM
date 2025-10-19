/**
 * @name NotImplemented is not an Exception
 * @description Detects code that raises 'NotImplemented' instead of 'NotImplementedError', which can lead to runtime type errors.
 * @kind problem
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raise-not-implemented
 * @tags reliability
 *       maintainability
 */

// Import standard Python analysis framework
import python

// Import specialized module for detecting NotImplemented misuse in exception handling
import Exceptions.NotImplemented

// Find expressions where NotImplemented is incorrectly used in raise statements
from Expr problematicExpr
where 
  // Identify expressions that represent NotImplemented in raise contexts
  use_of_not_implemented_in_raise(_, problematicExpr)
// Output the problematic expressions with a suggested fix
select problematicExpr, "NotImplemented is not an Exception. Did you mean NotImplementedError?"