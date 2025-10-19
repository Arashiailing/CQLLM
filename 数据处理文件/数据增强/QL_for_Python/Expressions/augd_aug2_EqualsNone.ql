/**
 * @name Testing equality to None
 * @description Detects inefficient and potentially incorrect comparisons to None using == operator,
 *              which should be replaced with the 'is' operator for identity testing.
 * @kind problem
 * @tags efficiency
 *       maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/test-equals-none
 */

import python

// Identify comparison expressions where None is being compared using equality operator
from Compare noneComparison
where 
    // Check if the comparison uses the equality operator (==)
    noneComparison.getOp(0) instanceof Eq
    // Verify that one of the comparators is the None literal
    and noneComparison.getAComparator() instanceof None
select noneComparison, "Testing for None should use the 'is' operator instead of '=='."