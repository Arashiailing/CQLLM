/**
 * @name NotImplemented is not an Exception
 * @description Detects code that raises NotImplemented instead of NotImplementedError, which can cause type errors since NotImplemented is not an exception class.
 * @kind problem
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raise-not-implemented
 * @tags reliability
 *       maintainability
 */

// Import Python analysis framework
import python

// Import module for detecting NotImplemented misusage
import Exceptions.NotImplemented

// Define the source of our analysis: expressions that use NotImplemented incorrectly
from Expr problematicExpr
// Filter expressions to only those that are used in raise statements
// This ensures we only catch actual raise statements using NotImplemented
where 
  // Check if the expression is a NotImplemented usage within a raise statement
  use_of_not_implemented_in_raise(_, problematicExpr)
// Output the problematic expression with a helpful message suggesting the correct exception
select problematicExpr, "NotImplemented is not an Exception. Did you mean NotImplementedError?"