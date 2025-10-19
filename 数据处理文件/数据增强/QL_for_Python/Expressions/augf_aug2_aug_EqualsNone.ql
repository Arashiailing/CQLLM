/**
 * @name Suboptimal None comparison using equality operator
 * @description Detects code locations where objects are compared to 'None' using the == operator.
 *              Such comparisons can cause unexpected behavior due to potential operator overloading.
 *              Identity comparison with None should be performed using the 'is' operator instead.
 * @kind problem
 * @tags efficiency
 *       maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/test-equals-none
 */

import python

// Locate comparison expressions that use equality operator with None
from Compare noneEqualityComparison
where 
    // Condition 1: The comparison uses the equality operator (==)
    noneEqualityComparison.getOp(0) instanceof Eq
    // Condition 2: One of the operands being compared is None
    and noneEqualityComparison.getAComparator() instanceof None
select noneEqualityComparison, "Testing for None should use the 'is' operator."