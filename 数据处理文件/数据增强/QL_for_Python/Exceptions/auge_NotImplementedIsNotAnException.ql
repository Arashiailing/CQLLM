/**
 * @name NotImplemented is not an Exception
 * @description Raising 'NotImplemented' constant causes type errors since it's not an exception type.
 *              Use 'NotImplementedError' instead for proper exception handling.
 * @kind problem
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raise-not-implemented
 * @tags reliability
 *       maintainability
 */

// Import standard Python analysis library
import python

// Import module defining NotImplemented exception predicates
import Exceptions.NotImplemented

// Identify expressions representing NotImplemented constants
from Expr problematicExpr
// Filter expressions used in raise statements
where use_of_not_implemented_in_raise(_, problematicExpr)
// Report problematic expressions with remediation guidance
select problematicExpr, "NotImplemented is not an Exception. Did you mean NotImplementedError?"