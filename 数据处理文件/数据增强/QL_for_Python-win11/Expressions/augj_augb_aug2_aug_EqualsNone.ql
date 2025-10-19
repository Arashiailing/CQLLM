/**
 * @name Inefficient None comparison using equality operator
 * @description Detects code locations where objects are compared to 'None' using the == operator,
 *              which may cause unexpected behavior due to potential operator overloading.
 *              It is recommended to use the 'is' operator for identity comparison with None.
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
from Compare noneCompareExpr
where 
    // The comparison must satisfy two conditions:
    // 1. It uses the equality operator (==)
    // 2. One of the operands is None
    noneCompareExpr.getOp(0) instanceof Eq and
    noneCompareExpr.getAComparator() instanceof None
select noneCompareExpr, "Testing for None should use the 'is' operator."