/**
 * @name NotImplemented is not an Exception
 * @description Detects code that raises 'NotImplemented' instead of 'NotImplementedError'.
 *              This pattern leads to runtime type errors because NotImplemented is not
 *              an exception class, but rather a special value used for binary operations.
 * @kind problem
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raise-not-implemented
 * @tags reliability
 *       maintainability
 */

// Core Python language analysis libraries
import python

// Specialized module for identifying NotImplemented misuse in exception handling
import Exceptions.NotImplemented

// Identify expressions where NotImplemented is incorrectly used in raise statements
from Expr problematicNotImplementedRaise
where 
    // Detect raise statements that misuse NotImplemented instead of the proper
    // NotImplementedError exception class
    use_of_not_implemented_in_raise(_, problematicNotImplementedRaise)
select 
    // Report the problematic expression with guidance for correction
    problematicNotImplementedRaise, "NotImplemented is not an Exception. Did you mean NotImplementedError?"