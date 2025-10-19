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
from Compare noneComparison
where 
    // Check if the comparison operator is equality (==)
    noneComparison.getOp(0) instanceof Eq
    // Check if one of the operands is None
    and noneComparison.getAComparator() instanceof None
select noneComparison, "Testing for None should use the 'is' operator."