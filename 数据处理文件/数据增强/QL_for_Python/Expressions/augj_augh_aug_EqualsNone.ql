/**
 * @name Testing equality to None
 * @description Detects inefficient and potentially incorrect comparisons of objects to 'None' using the == operator.
 * @kind problem
 * @tags efficiency
 *       maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/test-equals-none
 */

import python

// Identify comparison expressions that use equality operator with None
from Compare noneEqComparison
where 
    // Check if one of the operands is None
    noneEqComparison.getAComparator() instanceof None
    // Check if the comparison operator is equality (==)
    and noneEqComparison.getOp(0) instanceof Eq
select noneEqComparison, "Testing for None should use the 'is' operator."