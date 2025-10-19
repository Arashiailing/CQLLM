/**
 * @name NotImplemented is not an Exception
 * @description Detects raise statements that incorrectly use 'NotImplemented' 
 *              instead of 'NotImplementedError', which causes runtime type errors
 *              since NotImplemented is not an exception class.
 * @kind problem
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raise-not-implemented
 * @tags reliability
 *       maintainability
 */

// Import fundamental Python language analysis capabilities
import python

// Import specialized module for detecting NotImplemented misuse in exception handling
import Exceptions.NotImplemented

// Identify expressions where NotImplemented is incorrectly used in raise statements
from Expr problematicNotImplementedExpr
where 
    // Check for raise statements containing NotImplemented instead of the proper exception
    exists(Stmt enclosingStmt |
        use_of_not_implemented_in_raise(enclosingStmt, problematicNotImplementedExpr)
    )
select 
    // Display the problematic expression with suggested correction
    problematicNotImplementedExpr, "NotImplemented is not an Exception. Did you mean NotImplementedError?"