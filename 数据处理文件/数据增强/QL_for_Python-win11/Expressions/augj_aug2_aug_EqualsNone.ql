/**
 * @name Suboptimal None comparison using equality operator
 * @description Detects code locations where objects are compared to 'None' using the == operator,
 *              which may cause unexpected behavior due to possible operator overloading.
 *              The 'is' operator is recommended for identity comparison with None.
 *              
 *              In Python, comparing objects with None using == can lead to unexpected results
 *              because the == operator can be overridden by classes. The 'is' operator performs
 *              an identity comparison and is the preferred way to check if an object is None.
 * @kind problem
 * @tags efficiency
 *       maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/test-equals-none
 */

import python

// Identify comparison expressions where equality operator is used with None
from Compare noneEqualityCheck
where 
    // Condition 1: The comparison operation uses the equality operator (==)
    noneEqualityCheck.getOp(0) instanceof Eq
    // Condition 2: One of the operands in the comparison is the None singleton
    and noneEqualityCheck.getAComparator() instanceof None
select noneEqualityCheck, "Testing for None should use the 'is' operator."