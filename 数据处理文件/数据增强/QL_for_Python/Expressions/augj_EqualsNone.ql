/**
 * @name Testing equality to None
 * @description Detects inefficient and potentially incorrect comparisons to None using the == operator.
 *              In Python, 'is' operator should be used for identity comparison with None.
 * @kind problem
 * @tags efficiency
 *       maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/test-equals-none
 */

import python

// Identify comparison expressions where None is compared using equality operator
from Compare noneComparison
where 
    // Check if the comparison operator is equality (==)
    noneComparison.getOp(0) instanceof Eq and
    // Check if one of the comparands is None
    noneComparison.getAComparator() instanceof None
select noneComparison, "Testing for None should use the 'is' operator."