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
from Compare suboptimalNoneCheck
where 
    // Condition 1: The comparison uses the equality operator (==)
    suboptimalNoneCheck.getOp(0) instanceof Eq
    // Condition 2: One of the operands being compared is None
    and suboptimalNoneCheck.getAComparator() instanceof None
select suboptimalNoneCheck, "Testing for None should use the 'is' operator."