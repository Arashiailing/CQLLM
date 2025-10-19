/**
 * @name NotImplemented is not an Exception
 * @description Detects incorrect usage of 'NotImplemented' in raise statements instead of 'NotImplementedError'.
 *              This causes type errors since NotImplemented is a constant, not an exception class.
 * @kind problem
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raise-not-implemented
 * @tags reliability
 *       maintainability
 */

// Import Python core analysis library
import python

// Import specialized module for NotImplemented exception detection
import Exceptions.NotImplemented

// Identify expressions where NotImplemented is incorrectly raised as an exception
from Expr erroneousNotImplementedUsage
where 
    // Verify the expression represents NotImplemented used in a raise context
    use_of_not_implemented_in_raise(_, erroneousNotImplementedUsage)
// Report the problematic expression with suggested correction
select erroneousNotImplementedUsage, "NotImplemented is not an Exception. Did you mean NotImplementedError?"