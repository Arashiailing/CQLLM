/**
 * @name NotImplemented is not an Exception
 * @description Detects when 'NotImplemented' is incorrectly used as an exception in raise statements.
 *              This causes a type error since NotImplemented is not an exception class.
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

// Identify problematic raise statements using NotImplemented
from Expr problematicExpr
// Filter expressions where NotImplemented is used in raise contexts
where use_of_not_implemented_in_raise(_, problematicExpr)
// Report the issue with remediation guidance
select problematicExpr, "NotImplemented is not an Exception. Use NotImplementedError instead."