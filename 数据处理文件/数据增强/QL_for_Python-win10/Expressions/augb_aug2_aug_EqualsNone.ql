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

// Identify comparison expressions that use equality operator with None
from Compare noneEqualityComparison
where 
    // The comparison must use the equality operator (==)
    noneEqualityComparison.getOp(0) instanceof Eq
    // One of the operands must be None
    and noneEqualityComparison.getAComparator() instanceof None
select noneEqualityComparison, "Testing for None should use the 'is' operator."