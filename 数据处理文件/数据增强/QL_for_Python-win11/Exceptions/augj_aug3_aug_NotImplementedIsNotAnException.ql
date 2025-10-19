/**
 * @name NotImplemented is not an Exception
 * @description Identifies instances where 'NotImplemented' is raised instead of the proper 'NotImplementedError', 
 *              which can cause type-related issues at runtime.
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

// Define the main query to detect incorrect NotImplemented usage in raise statements
from Expr incorrectlyRaisedExpr
where 
  // Identify expressions where NotImplemented is used in a raise context
  // This is problematic because NotImplemented is not an exception type
  exists(Expr raisedValue | 
    use_of_not_implemented_in_raise(_, raisedValue) and 
    raisedValue = incorrectlyRaisedExpr
  )
// Report the problematic expression with a corrective suggestion
select incorrectlyRaisedExpr, "NotImplemented is not an Exception. Did you mean NotImplementedError?"