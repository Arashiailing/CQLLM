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

// Core Python analysis framework imports
import python

// Specialized module for NotImplemented exception analysis
import Exceptions.NotImplemented

// Identify problematic expressions raising NotImplemented instead of NotImplementedError
from Expr problematicExpr
where 
  // Check for NotImplemented usage in raise statement context
  use_of_not_implemented_in_raise(_, problematicExpr)
// Report findings with corrective guidance
select problematicExpr, "NotImplemented is not an Exception. Did you mean NotImplementedError?"