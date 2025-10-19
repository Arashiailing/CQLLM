/**
 * @name Suboptimal None comparison using equality operator
 * @description Detects code locations where objects are compared to 'None' using == operator,
 *              which may cause unexpected behavior due to operator overloading.
 *              Identity comparison with 'is' operator is recommended for None checks.
 * @kind problem
 * @tags efficiency
 *       maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/test-equals-none
 */

import python

// Identify equality comparisons with None that should use identity comparison instead
from Compare noneEqualityComparison
where 
    // Check if the comparison uses the equality operator (==)
    noneEqualityComparison.getOp(0) instanceof Eq
    // Verify that one of the operands in the comparison is the None literal
    and noneEqualityComparison.getAComparator() instanceof None
select noneEqualityComparison, "Testing for None should use the 'is' operator."