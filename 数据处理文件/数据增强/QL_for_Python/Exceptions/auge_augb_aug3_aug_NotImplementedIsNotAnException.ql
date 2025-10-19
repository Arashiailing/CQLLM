/**
 * @name NotImplemented is not an Exception
 * @description Detects improper use of 'NotImplemented' in raise statements where 'NotImplementedError' should be used
 * @kind problem
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raise-not-implemented
 * @tags reliability
 *       maintainability
 */

// Core Python analysis imports
import python

// Specialized analysis module for NotImplemented exception handling
import Exceptions.NotImplemented

// Identify problematic raise expressions using NotImplemented instead of NotImplementedError
from Expr problematicRaiseExpr
where 
  // Verify the expression represents a NotImplemented usage in raise context
  use_of_not_implemented_in_raise(_, problematicRaiseExpr)
// Report the problematic expression with corrective guidance
select problematicRaiseExpr, "NotImplemented is not an Exception. Did you mean NotImplementedError?"