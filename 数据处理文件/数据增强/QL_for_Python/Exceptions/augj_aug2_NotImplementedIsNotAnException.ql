/**
 * @name NotImplemented is not an Exception
 * @description Identifies incorrect usage of 'NotImplemented' in raise statements.
 *              'NotImplemented' is a constant value, not an exception class, and should not be raised.
 *              This can lead to runtime type errors. The correct exception to use is 'NotImplementedError'.
 * @kind problem
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raise-not-implemented
 * @tags reliability
 *       maintainability
 */

import python
import Exceptions.NotImplemented

// Identify expressions where NotImplemented is used in raise statements
from Expr problematicNotImplementedUsage
// Filter cases where NotImplemented appears in raise contexts
where use_of_not_implemented_in_raise(_, problematicNotImplementedUsage)
// Report the problematic expression with remediation guidance
select problematicNotImplementedUsage, "NotImplemented is not an Exception. Use NotImplementedError instead."