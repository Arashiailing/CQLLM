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

// Counts elements in an expression list
private int countExpressionListElements(ExprList expressionList) { 
    result = count(expressionList.getAnItem()) 
}

from Assign assignment, int leftSideCount, int rightSideCount, Location errorLocation, string containerType
where
    // Case 1: Direct tuple/list unpacking with mismatched element counts
    exists(ExprList leftHandElements, ExprList rightHandElements |
        (
            // Verify left side is tuple or list unpacking
            assignment.getATarget().(Tuple).getElts() = leftHandElements or
            assignment.getATarget().(List).getElts() = leftHandElements
        ) and
        (
            // Verify right side is tuple or list
            (assignment.getValue().(Tuple).getElts() = rightHandElements and containerType = "tuple") or
            (assignment.getValue().(List).getElts() = rightHandElements and containerType = "list")
        ) and
        // Calculate and compare element counts
        leftSideCount = countExpressionListElements(leftHandElements) and
        rightSideCount = countExpressionListElements(rightHandElements) and
        leftSideCount != rightSideCount and
        // Ensure no starred unpacking on either side
        not exists(Starred unpacking | 
            leftHandElements.getAnItem() = unpacking or 
            rightHandElements.getAnItem() = unpacking
        ) and
        // Identify error location
        errorLocation = assignment.getValue().getLocation()
    )
    or
    // Case 2: Indirect tuple unpacking via reference
    exists(ExprList leftHandElements, TupleValue referencedTuple, AstNode tupleSource |
        (
            // Verify left side is tuple or list unpacking
            assignment.getATarget().(Tuple).getElts() = leftHandElements or
            assignment.getATarget().(List).getElts() = leftHandElements
        ) and
        // Verify right side references a tuple value
        assignment.getValue().pointsTo(referencedTuple, tupleSource) and
        // Calculate and compare element counts
        leftSideCount = countExpressionListElements(leftHandElements) and
        rightSideCount = referencedTuple.length() and
        leftSideCount != rightSideCount and
        // Ensure no starred unpacking on left side
        not leftHandElements.getAnItem() instanceof Starred and
        // Identify error location and container type
        errorLocation = tupleSource.getLocation() and
        containerType = "tuple"
    )
select assignment,
    // Generate descriptive error message
    "Left hand side of assignment contains " + leftSideCount +
    " variables, but right hand side is a $@ of length " + rightSideCount + ".", 
    errorLocation, containerType