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

// Import Python analysis framework
import python

// Import module for detecting NotImplemented misusage
import Exceptions.NotImplemented

// Find all expressions that incorrectly use NotImplemented
from Expr notImplementedUsage
// Filter to identify only those expressions that appear in raise statements
where use_of_not_implemented_in_raise(_, notImplementedUsage)
// Present the problematic code along with corrective guidance
select notImplementedUsage, "NotImplemented is not an Exception. Did you mean NotImplementedError?"