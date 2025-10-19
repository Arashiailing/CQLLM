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

// Helper function to determine the number of expressions in a list
private int calculateExpressionCount(ExprList expressionList) { 
    result = count(expressionList.getAnItem()) 
}

from Assign assignStmt, int lhsCount, int rhsCount, Location errorLoc, string containerKind
where
    // Case 1: Direct tuple/list assignment with mismatched element counts
    exists(ExprList lhsElements, ExprList rhsElements |
        // Verify that assignment target is a tuple or list
        (
            assignStmt.getATarget().(Tuple).getElts() = lhsElements or
            assignStmt.getATarget().(List).getElts() = lhsElements
        ) and
        // Verify that assignment source is a tuple or list
        (
            (assignStmt.getValue().(Tuple).getElts() = rhsElements and containerKind = "tuple") or
            (assignStmt.getValue().(List).getElts() = rhsElements and containerKind = "list")
        ) and
        // Calculate and compare element counts on both sides
        lhsCount = calculateExpressionCount(lhsElements) and
        rhsCount = calculateExpressionCount(rhsElements) and
        lhsCount != rhsCount and
        // Ensure neither side uses starred expressions for unpacking
        not exists(Starred starExpr | 
            lhsElements.getAnItem() = starExpr or 
            rhsElements.getAnItem() = starExpr
        ) and
        // Set the error location to the value being assigned
        errorLoc = assignStmt.getValue().getLocation()
    )
    or
    // Case 2: Assignment via reference to a tuple with mismatched element counts
    exists(ExprList lhsElements, TupleValue rhsTupleValue, AstNode tupleSource |
        // Verify that assignment target is a tuple or list
        (
            assignStmt.getATarget().(Tuple).getElts() = lhsElements or
            assignStmt.getATarget().(List).getElts() = lhsElements
        ) and
        // Verify that assignment source points to a tuple value
        assignStmt.getValue().pointsTo(rhsTupleValue, tupleSource) and
        // Calculate and compare element counts
        lhsCount = calculateExpressionCount(lhsElements) and
        rhsCount = rhsTupleValue.length() and
        lhsCount != rhsCount and
        // Ensure left side doesn't use starred expressions
        not lhsElements.getAnItem() instanceof Starred and
        // Set error location and container type
        errorLoc = tupleSource.getLocation() and
        containerKind = "tuple"
    )
select assignStmt,
    // Generate descriptive error message
    "Left hand side of assignment contains " + lhsCount +
    " variables, but right hand side is a $@ of length " + rhsCount + ".", 
    errorLoc, containerKind