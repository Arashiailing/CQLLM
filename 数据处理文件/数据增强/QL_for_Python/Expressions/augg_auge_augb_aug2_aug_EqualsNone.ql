/**
 * @name Suboptimal None comparison using equality operator
 * @description Detects code locations where objects are compared to 'None' using the == operator,
 *              which may cause unexpected behavior due to potential operator overloading.
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

// Identify comparison expressions involving None equality checks
from Compare noneComparison
where 
    // Check for equality operator usage
    noneComparison.getOp(0) instanceof Eq
    // Verify one operand is the None literal
    and exists(None noneLiteral | noneComparison.getAComparator() = noneLiteral)
select noneComparison, "Testing for None should use the 'is' operator."