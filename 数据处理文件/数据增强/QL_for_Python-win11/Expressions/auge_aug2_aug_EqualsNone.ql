/**
 * @name Suboptimal None comparison using equality operator
 * @description Identifies code locations where objects are compared to 'None' using the == operator,
 *              which can lead to unexpected behavior due to potential operator overloading.
 *              The 'is' operator should be used for identity comparison with None.
 * 
 * @description detailed
 * In Python, comparing objects to None using the equality operator (==) is suboptimal because
 * it relies on the __eq__ method of the object, which can be overridden. This can lead to
 * unexpected behavior if an object's __eq__ method returns True when compared to None.
 * The identity operator 'is' should be used instead, as it checks if two references point to
 * the same object, which is the correct way to check for None.
 * 
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
    // The comparison uses the equality operator (==)
    noneEqualityComparison.getOp(0) instanceof Eq
    // One of the operands being compared is None
    and noneEqualityComparison.getAComparator() instanceof None
select noneEqualityComparison, "Testing for None should use the 'is' operator."