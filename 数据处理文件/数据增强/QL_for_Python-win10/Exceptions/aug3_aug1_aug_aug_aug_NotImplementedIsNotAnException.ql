/**
 * @name NotImplemented is not an Exception
 * @description Detects code that raises 'NotImplemented' instead of 'NotImplementedError',
 *              which causes runtime type errors since NotImplemented is not an exception class.
 * @kind problem
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raise-not-implemented
 * @tags reliability
 *       maintainability
 */

// Core Python language analysis components
import python

// Specialized module for identifying NotImplemented misuse in exception contexts
import Exceptions.NotImplemented

// Identify expressions where NotImplemented is incorrectly used in raise statements
from Expr problematicNotImplementedRaise
where 
    // Locate raise statements that use NotImplemented instead of the proper NotImplementedError
    use_of_not_implemented_in_raise(_, problematicNotImplementedRaise)
select 
    // Report the problematic expression with remediation guidance
    problematicNotImplementedRaise, "NotImplemented is not an Exception. Did you mean NotImplementedError?"