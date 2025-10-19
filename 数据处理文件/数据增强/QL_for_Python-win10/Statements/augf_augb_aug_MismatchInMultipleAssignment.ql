/**
 * @name Mismatch in multiple assignment
 * @description Identifies assignments where the number of variables on the left 
 *              doesn't match the number of elements in the right-hand container,
 *              leading to runtime exceptions.
 * @kind problem
 * @tags reliability
 *       correctness
 *       types
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/mismatched-multiple-assignment
 */

import python

// Calculates the number of elements in an expression list
private int calculateElementCount(ExprList exprList) { 
    result = count(exprList.getAnItem()) 
}

from Assign assignment, int leftCount, int rightCount, Location errorLocation, string containerType
where
    // Scenario 1: Direct unpacking from tuple/list with count mismatch
    exists(ExprList leftExprs, ExprList rightExprs |
        // Left side is tuple/list unpacking
        (assignment.getATarget().(Tuple).getElts() = leftExprs or
         assignment.getATarget().(List).getElts() = leftExprs) and
        // Right side is tuple/list
        ((assignment.getValue().(Tuple).getElts() = rightExprs and containerType = "tuple") or
         (assignment.getValue().(List).getElts() = rightExprs and containerType = "list")) and
        // Calculate element counts
        leftCount = calculateElementCount(leftExprs) and
        rightCount = calculateElementCount(rightExprs) and
        leftCount != rightCount and
        // Verify no starred unpacking on either side
        not exists(Starred unpacking | 
            leftExprs.getAnItem() = unpacking or 
            rightExprs.getAnItem() = unpacking
        ) and
        // Set error location to right-hand expression
        errorLocation = assignment.getValue().getLocation()
    )
    or
    // Scenario 2: Indirect unpacking via tuple reference
    exists(ExprList leftExprs, TupleValue referencedTuple, AstNode tupleSource |
        // Left side is tuple/list unpacking
        (assignment.getATarget().(Tuple).getElts() = leftExprs or
         assignment.getATarget().(List).getElts() = leftExprs) and
        // Right side references a tuple value
        assignment.getValue().pointsTo(referencedTuple, tupleSource) and
        // Calculate element counts
        leftCount = calculateElementCount(leftExprs) and
        rightCount = referencedTuple.length() and
        leftCount != rightCount and
        // Verify no starred unpacking on left side
        not leftExprs.getAnItem() instanceof Starred and
        // Set error location and container type
        errorLocation = tupleSource.getLocation() and
        containerType = "tuple"
    )
select assignment,
    // Generate descriptive error message
    "Left hand side of assignment contains " + leftCount +
    " variables, but right hand side is a $@ of length " + rightCount + ".", 
    errorLocation, containerType