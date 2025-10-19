/**
 * @name Testing equality to None
 * @description Detects inefficient and potentially incorrect None comparisons using == operator.
 * @kind problem
 * @tags efficiency
 *       maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/test-equals-none
 */

import python

// Identify comparison operations where:
// 1. The operator is equality (==)
// 2. One of the compared operands is None
from Compare comparison
where 
  comparison.getOp(0) instanceof Eq  // Check for equality operator
  and comparison.getAComparator() instanceof None  // Check for None operand
select comparison, "Testing for None should use the 'is' operator."  // Report with recommendation