/**
 * @name NotImplemented is not an Exception
 * @description Detects when 'NotImplemented' is raised instead of 'NotImplementedError', which leads to type errors.
 * @kind problem
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raise-not-implemented
 * @tags reliability
 *       maintainability
 */

// Import core Python analysis functionality
import python

// Import specialized module for NotImplemented exception analysis
import Exceptions.NotImplemented

// Find expressions that incorrectly use NotImplemented in raise statements
from Expr problematicExpr
where 
  // Check if the expression represents a NotImplemented usage in a raise context
  use_of_not_implemented_in_raise(_, problematicExpr)
// Output the problematic expression with suggested correction
select problematicExpr, "NotImplemented is not an Exception. Did you mean NotImplementedError?"