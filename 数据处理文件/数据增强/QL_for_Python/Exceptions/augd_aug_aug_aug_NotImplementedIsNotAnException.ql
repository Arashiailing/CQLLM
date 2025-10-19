/**
 * @name NotImplemented is not an Exception
 * @description Identifies incorrect usage of 'NotImplemented' in raise statements where
 *              an exception type is required. Using 'NotImplemented' instead of 
 *              'NotImplementedError' will cause runtime type errors when raised.
 * @kind problem
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raise-not-implemented
 * @tags reliability
 *       maintainability
 */

// Import core Python language analysis capabilities
import python

// Import specialized analysis for NotImplemented exception misuse detection
import Exceptions.NotImplemented

// Define the source of problematic raise statements
from Expr incorrectRaiseStatement
where 
    // Detect raise statements that incorrectly use NotImplemented instead of NotImplementedError
    exists(Expr raisedExpr | 
        use_of_not_implemented_in_raise(_, raisedExpr) and 
        raisedExpr = incorrectRaiseStatement
    )
select 
    // Output the problematic expression with guidance for correction
    incorrectRaiseStatement, "NotImplemented is not an Exception. Did you mean NotImplementedError?"