/**
 * @name NotImplemented is not an Exception
 * @description Detects incorrect usage of 'NotImplemented' as an exception in raise statements,
 *              which will cause a type error at runtime.
 * @kind problem
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raise-not-implemented
 * @tags reliability
 *       maintainability
 */

// Import Python analysis framework for code analysis capabilities
import python

// Import specialized module for detecting NotImplemented exception handling issues
import Exceptions.NotImplemented

// Query to find expressions where NotImplemented is incorrectly used in raise contexts
from Expr incorrectNotImplementedUsage
// Apply filter to identify cases where NotImplemented is misused in raise statements
where use_of_not_implemented_in_raise(_, incorrectNotImplementedUsage)
// Display results showing the problematic code along with a suggested correction
select incorrectNotImplementedUsage, "NotImplemented is not an Exception. Did you mean NotImplementedError?"