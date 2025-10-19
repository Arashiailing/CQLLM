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

from Expr problematicNotImplementedUsage
where use_of_not_implemented_in_raise(_, problematicNotImplementedUsage)
select problematicNotImplementedUsage, "NotImplemented is not an Exception. Did you mean NotImplementedError?"