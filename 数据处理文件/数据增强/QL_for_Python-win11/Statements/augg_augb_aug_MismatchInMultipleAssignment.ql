/**
 * @name Mismatch in multiple assignment
 * @description Detects assignments where the number of variables on the left 
 *              doesn't match the number of elements in the right-hand container,
 *              causing runtime exceptions.
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

// Helper function to count the number of elements in an expression list
private int countElementsInExprList(ExprList exprList) { 
    result = count(exprList.getAnItem()) 
}

from Assign stmt, int lhsCount, int rhsCount, Location errorLoc, string containerKind
where
    // Case 1: Direct unpacking of tuples/lists with mismatched element counts
    exists(ExprList lhsElements, ExprList rhsElements |
        (
            // Check if left side is tuple or list unpacking
            stmt.getATarget().(Tuple).getElts() = lhsElements or
            stmt.getATarget().(List).getElts() = lhsElements
        ) and
        (
            // Check if right side is tuple or list
            (stmt.getValue().(Tuple).getElts() = rhsElements and containerKind = "tuple") or
            (stmt.getValue().(List).getElts() = rhsElements and containerKind = "list")
        ) and
        // Calculate and compare element counts
        lhsCount = countElementsInExprList(lhsElements) and
        rhsCount = countElementsInExprList(rhsElements) and
        lhsCount != rhsCount and
        // Ensure no starred unpacking on either side
        not exists(Starred unpacking | 
            lhsElements.getAnItem() = unpacking or 
            rhsElements.getAnItem() = unpacking
        ) and
        // Determine error location
        errorLoc = stmt.getValue().getLocation()
    )
    or
    // Case 2: Indirect tuple unpacking through a reference
    exists(ExprList lhsElements, TupleValue refTuple, AstNode tupleOrigin |
        (
            // Check if left side is tuple or list unpacking
            stmt.getATarget().(Tuple).getElts() = lhsElements or
            stmt.getATarget().(List).getElts() = lhsElements
        ) and
        // Check if right side references a tuple value
        stmt.getValue().pointsTo(refTuple, tupleOrigin) and
        // Calculate and compare element counts
        lhsCount = countElementsInExprList(lhsElements) and
        rhsCount = refTuple.length() and
        lhsCount != rhsCount and
        // Ensure no starred unpacking on left side
        not lhsElements.getAnItem() instanceof Starred and
        // Determine error location and container type
        errorLoc = tupleOrigin.getLocation() and
        containerKind = "tuple"
    )
select stmt,
    // Create a descriptive error message
    "Left hand side of assignment contains " + lhsCount +
    " variables, but right hand side is a $@ of length " + rhsCount + ".", 
    errorLoc, containerKind