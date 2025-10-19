/**
 * @name NotImplemented is not an Exception
 * @description Identifies incorrect usage of 'NotImplemented' in raise statements where 'NotImplementedError' should be used instead
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

// Identify expressions that incorrectly raise NotImplemented instead of NotImplementedError
from Expr erroneousExpr
where 
  // Check if the expression represents a NotImplemented usage in a raise context
  use_of_not_implemented_in_raise(_, erroneousExpr)
// Report the problematic expression with corrective suggestion
select erroneousExpr, "NotImplemented is not an Exception. Did you mean NotImplementedError?"