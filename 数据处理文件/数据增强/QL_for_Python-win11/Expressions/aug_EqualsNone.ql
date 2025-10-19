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
from Compare noneEqualityTest
where 
    // The comparison uses the equality operator (==)
    noneEqualityTest.getOp(0) instanceof Eq
    // One of the operands being compared is None
    and noneEqualityTest.getAComparator() instanceof None
select noneEqualityTest, "Testing for None should use the 'is' operator."