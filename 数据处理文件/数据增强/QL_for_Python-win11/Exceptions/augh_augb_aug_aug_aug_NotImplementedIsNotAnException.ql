/**
 * @name NotImplemented is not an Exception
 * @description Detects code raising 'NotImplemented' instead of 'NotImplementedError'.
 *              This causes runtime type errors as 'NotImplemented' is not an exception class.
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

// Specialized analysis for NotImplemented misuse detection
import Exceptions.NotImplemented

// Identify problematic raise statements using NotImplemented
from Expr problematicExpr
where 
    // Check for raise statements with incorrect NotImplemented usage
    use_of_not_implemented_in_raise(_, problematicExpr)
select 
    // Report the expression with corrective guidance
    problematicExpr, "NotImplemented is not an Exception. Did you mean NotImplementedError?"