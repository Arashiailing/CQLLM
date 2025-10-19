/**
 * @name NotImplemented is not an Exception
 * @description Identifies incorrect usage of 'NotImplemented' in raise statements,
 *              which triggers runtime type errors due to its non-exception nature.
 * @kind problem
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raise-not-implemented
 * @tags reliability
 *       maintainability
 */

// Core Python analysis framework
import python

// Module for handling NotImplemented-related exceptions
import Exceptions.NotImplemented

// Identify problematic expressions where NotImplemented is raised
from Expr notImplementedUsage
// Filter expressions where NotImplemented appears in raise contexts
where use_of_not_implemented_in_raise(_, notImplementedUsage)
// Output the problematic expression with corrective guidance
select notImplementedUsage, "NotImplemented is not an Exception. Did you mean NotImplementedError?"