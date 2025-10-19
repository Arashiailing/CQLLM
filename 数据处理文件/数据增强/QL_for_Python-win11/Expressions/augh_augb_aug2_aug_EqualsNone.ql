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

// Identify problematic equality comparisons with None
from Compare badNoneComp
where 
    // Check if comparison uses equality operator
    badNoneComp.getOp(0) instanceof Eq
    // Verify one operand is None literal
    and badNoneComp.getAComparator() instanceof None
select badNoneComp, "Testing for None should use the 'is' operator."