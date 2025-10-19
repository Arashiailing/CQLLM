/**
 * @name Suboptimal None comparison using equality operator
 * @description Identifies code locations where objects are compared to 'None' using the == operator,
 *              which can lead to unexpected behavior due to potential operator overloading.
 *              The 'is' operator should be used for identity comparison with None.
 * @kind problem
 * @tags efficiency
 *       maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/test-equals-none
 */

import python

// Find comparison expressions where None is compared using equality operator
from Compare noneEqualityExpr
where 
    // Condition 1: The comparison must use the equality operator (==)
    noneEqualityExpr.getOp(0) instanceof Eq
    // Condition 2: One of the operands must be the None literal
    and noneEqualityExpr.getAComparator() instanceof None
select noneEqualityExpr, "Testing for None should use the 'is' operator."