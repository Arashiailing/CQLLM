/**
 * @name NotImplemented is not an Exception
 * @description Detects code raising 'NotImplemented' instead of 'NotImplementedError'.
 *              This causes runtime type errors since 'NotImplemented' isn't an exception class.
 * @kind problem
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raise-not-implemented
 * @tags reliability
 *       maintainability
 */

// Core Python analysis capabilities
import python

// Specialized detection for NotImplemented misuse
import Exceptions.NotImplemented

// Identify problematic raise statements
from Expr problematicExpr
where 
    // Find raise statements using NotImplemented instead of proper exception
    use_of_not_implemented_in_raise(_, problematicExpr)
select 
    // Report the expression with correction guidance
    problematicExpr, "NotImplemented is not an Exception. Did you mean NotImplementedError?"