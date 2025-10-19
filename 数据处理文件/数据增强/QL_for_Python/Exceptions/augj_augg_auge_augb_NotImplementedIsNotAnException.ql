/**
 * @name NotImplemented is not an Exception
 * @description Detects incorrect usage of 'NotImplemented' in raise statements,
 *              causing runtime type errors instead of proper exception handling.
 * @kind problem
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raise-not-implemented
 * @tags reliability
 *       maintainability
 */

// Import core Python analysis framework
import python

// Import specialized module for NotImplemented exception analysis
import Exceptions.NotImplemented

// Define the analysis source: expressions misusing NotImplemented in raise contexts
from Expr problematicRaiseExpr
// Apply filtering logic to identify problematic raise expressions
where 
    // Verify the expression represents improper NotImplemented usage in raise statements
    use_of_not_implemented_in_raise(_, problematicRaiseExpr)
// Report findings with corrective guidance message
select problematicRaiseExpr, "NotImplemented is not an Exception. Did you mean NotImplementedError?"