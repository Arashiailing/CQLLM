/**
 * @name NotImplemented is not an Exception
 * @description Raising 'NotImplemented' instead of 'NotImplementedError' will cause a type error.
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

// Identify expressions where NotImplemented is incorrectly raised
from Expr notImplementedExpression
where 
  // Filter expressions used in raise statements with NotImplemented
  use_of_not_implemented_in_raise(_, notImplementedExpression)
// Report problematic expressions with fix suggestion
select notImplementedExpression, "NotImplemented is not an Exception. Did you mean NotImplementedError?"