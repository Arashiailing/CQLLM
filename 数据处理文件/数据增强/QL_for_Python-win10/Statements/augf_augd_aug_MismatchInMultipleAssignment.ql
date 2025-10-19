/**
 * @name Mismatch in multiple assignment
 * @description Detects assignments where the number of variables on the left side
 *              doesn't match the number of elements in the container on the right side,
 *              which would cause a runtime exception.
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

// Helper function to count expressions in an expression list
private int countExpressions(ExprList exprList) { 
    result = count(exprList.getAnItem()) 
}

from Assign assignStmt, int leftCount, int rightCount, Location errorLocation, string containerType
where
    // Case 1: Direct tuple/list assignment with mismatched element counts
    exists(ExprList leftExprs, ExprList rightExprs |
        // Verify assignment target is a tuple or list
        (
            assignStmt.getATarget().(Tuple).getElts() = leftExprs or
            assignStmt.getATarget().(List).getElts() = leftExprs
        ) and
        // Verify assignment source is a tuple or list
        (
            (assignStmt.getValue().(Tuple).getElts() = rightExprs and containerType = "tuple") or
            (assignStmt.getValue().(List).getElts() = rightExprs and containerType = "list")
        ) and
        // Calculate and compare element counts
        leftCount = countExpressions(leftExprs) and
        rightCount = countExpressions(rightExprs) and
        leftCount != rightCount and
        // Ensure no starred expressions on either side
        not exists(Starred starExpr | 
            leftExprs.getAnItem() = starExpr or 
            rightExprs.getAnItem() = starExpr
        ) and
        // Set error location to the assigned value
        errorLocation = assignStmt.getValue().getLocation()
    )
    or
    // Case 2: Assignment via tuple reference with mismatched element counts
    exists(ExprList leftExprs, TupleValue rightTuple, AstNode tupleOrigin |
        // Verify assignment target is a tuple or list
        (
            assignStmt.getATarget().(Tuple).getElts() = leftExprs or
            assignStmt.getATarget().(List).getElts() = leftExprs
        ) and
        // Verify assignment source points to a tuple value
        assignStmt.getValue().pointsTo(rightTuple, tupleOrigin) and
        // Calculate and compare element counts
        leftCount = countExpressions(leftExprs) and
        rightCount = rightTuple.length() and
        leftCount != rightCount and
        // Ensure no starred expressions on left side
        not leftExprs.getAnItem() instanceof Starred and
        // Set error location and container type
        errorLocation = tupleOrigin.getLocation() and
        containerType = "tuple"
    )
select assignStmt,
    // Generate descriptive error message
    "Left hand side of assignment contains " + leftCount +
    " variables, but right hand side is a $@ of length " + rightCount + ".", 
    errorLocation, containerType