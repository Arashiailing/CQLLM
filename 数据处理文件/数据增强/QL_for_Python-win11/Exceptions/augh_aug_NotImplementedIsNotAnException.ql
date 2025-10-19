/**
 * @name NotImplemented is not an Exception
 * @description Detects code that raises 'NotImplemented' instead of the proper 'NotImplementedError' exception.
 *              This pattern causes type errors since NotImplemented is intended for comparison methods.
 * @kind problem
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raise-not-implemented
 * @tags reliability
 *       maintainability
 */

// Import Python analysis library
import python

// Import module containing NotImplemented exception handling logic
import Exceptions.NotImplemented

// Find problematic raise expressions that use NotImplemented instead of NotImplementedError
from Expr problematicRaiseExpr
where 
  // Identify expressions where NotImplemented is incorrectly used in raise statements
  use_of_not_implemented_in_raise(_, problematicRaiseExpr)
// Output the problematic expression with a helpful fix suggestion
select problematicRaiseExpr, "NotImplemented is not an Exception. Did you mean NotImplementedError?"