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

// Import core Python analysis capabilities
import python

// Import specialized exception handling analysis for NotImplemented
import Exceptions.NotImplemented

// Identify problematic raise statements using NotImplemented instead of NotImplementedError
from Expr problematicRaiseExpr
where 
  // Locate expressions where NotImplemented is incorrectly used in raise contexts
  use_of_not_implemented_in_raise(_, problematicRaiseExpr)
// Report findings with corrective guidance
select problematicRaiseExpr, "NotImplemented is not an Exception. Did you mean NotImplementedError?"