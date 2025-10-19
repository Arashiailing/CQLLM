/**
 * @name Testing equality to None
 * @description Detects inefficient and potentially incorrect comparisons to None using == operator.
 * @kind problem
 * @tags efficiency
 *       maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/test-equals-none
 */

import python

// Identify comparison expressions that use == operator with None
from Compare comparisonExpr
where 
    // Check if the comparison operator is equality (==)
    comparisonExpr.getOp(0) instanceof Eq
    // Check if one of the compared values is None
    and comparisonExpr.getAComparator() instanceof None
select comparisonExpr, "Testing for None should use the 'is' operator."