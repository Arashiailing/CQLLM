/**
 * @name NotImplemented is not an Exception
 * @description Identifies code that incorrectly raises 'NotImplemented' 
 *              instead of the proper 'NotImplementedError' exception.
 *              This pattern leads to type errors because NotImplemented is designed 
 *              for comparison method return values, not as an exception.
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

// Import module for handling NotImplemented-related exception analysis
import Exceptions.NotImplemented

// Identify raise statements that incorrectly use NotImplemented instead of NotImplementedError
from Expr erroneousRaiseExpression
where 
  // The following predicate detects expressions where NotImplemented is misused in raise statements
  use_of_not_implemented_in_raise(_, erroneousRaiseExpression)
// Report the problematic expression with a suggested correction
select erroneousRaiseExpression, "NotImplemented is not an Exception. Did you mean NotImplementedError?"