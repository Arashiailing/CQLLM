/**
 * @name NotImplemented is not an Exception
 * @description Identifies instances where 'NotImplemented' is used in raise statements instead of 'NotImplementedError', leading to type errors.
 * @kind problem
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raise-not-implemented
 * @tags reliability
 *       maintainability
 */

// Import the Python analysis framework
import python

// Import specialized module for detecting NotImplemented misusage
import Exceptions.NotImplemented

// Identify problematic expressions using NotImplemented in raise statements
from Expr problematicExpr
// Filter expressions that represent incorrect NotImplemented usage in raise contexts
where use_of_not_implemented_in_raise(_, problematicExpr)
// Output the problematic expression with corrective guidance
select problematicExpr, "NotImplemented is not an Exception. Did you mean NotImplementedError?"