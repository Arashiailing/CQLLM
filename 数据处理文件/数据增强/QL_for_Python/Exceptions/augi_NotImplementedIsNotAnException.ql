/**
 * @name NotImplemented is not an Exception
 * @description Identifies incorrect usage of 'NotImplemented' in raise statements.
 *              'NotImplemented' is a special value in Python, not an exception class.
 *              Using it in raise statements causes runtime TypeErrors. Developers should
 *              use 'NotImplementedError' exception class instead.
 * @kind problem
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raise-not-implemented
 * @tags reliability
 *       maintainability
 */

// Import Python language support for code analysis
import python

// Import module for detecting NotImplemented exception misuse
import Exceptions.NotImplemented

// Define source: expressions representing NotImplemented usage
from Expr notImplementedUsage
// Apply filter to identify raise statements containing NotImplemented
where use_of_not_implemented_in_raise(_, notImplementedUsage)
// Output problematic expressions with remediation guidance
select notImplementedUsage, "NotImplemented is not an Exception. Did you mean NotImplementedError?"