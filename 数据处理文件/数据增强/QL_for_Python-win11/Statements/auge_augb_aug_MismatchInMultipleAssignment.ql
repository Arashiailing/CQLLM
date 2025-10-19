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

// Helper function to count elements in an expression list
private int countExpressionListElements(ExprList exprList) { 
    result = count(exprList.getAnItem()) 
}

from Assign assignment, int lhsCount, int rhsCount, Location errLoc, string containerKind
where
    // Case 1: Direct tuple/list unpacking with mismatched element counts
    exists(ExprList lhsElements, ExprList rhsElements |
        // Check if left side is tuple or list unpacking
        (
            assignment.getATarget().(Tuple).getElts() = lhsElements or
            assignment.getATarget().(List).getElts() = lhsElements
        ) and
        // Check if right side is tuple or list
        (
            (assignment.getValue().(Tuple).getElts() = rhsElements and containerKind = "tuple") or
            (assignment.getValue().(List).getElts() = rhsElements and containerKind = "list")
        ) and
        // Calculate and compare element counts
        lhsCount = countExpressionListElements(lhsElements) and
        rhsCount = countExpressionListElements(rhsElements) and
        lhsCount != rhsCount and
        // Ensure no starred unpacking on either side
        not exists(Starred starExpr | 
            lhsElements.getAnItem() = starExpr or 
            rhsElements.getAnItem() = starExpr
        ) and
        // Identify error location
        errLoc = assignment.getValue().getLocation()
    )
    or
    // Case 2: Indirect tuple unpacking via reference
    exists(ExprList lhsElements, TupleValue tupleRef, AstNode tupleSrc |
        // Check if left side is tuple or list unpacking
        (
            assignment.getATarget().(Tuple).getElts() = lhsElements or
            assignment.getATarget().(List).getElts() = lhsElements
        ) and
        // Check if right side references a tuple value
        assignment.getValue().pointsTo(tupleRef, tupleSrc) and
        // Calculate and compare element counts
        lhsCount = countExpressionListElements(lhsElements) and
        rhsCount = tupleRef.length() and
        lhsCount != rhsCount and
        // Ensure no starred unpacking on left side
        not lhsElements.getAnItem() instanceof Starred and
        // Identify error location and container type
        errLoc = tupleSrc.getLocation() and
        containerKind = "tuple"
    )
select assignment,
    // Generate descriptive error message
    "Left hand side of assignment contains " + lhsCount +
    " variables, but right hand side is a $@ of length " + rhsCount + ".", 
    errLoc, containerKind