/**
 * @name Mismatch in multiple assignment
 * @description Detects assignments where the number of variables on the left
 *              doesn't match the number of elements in the right-hand sequence.
 *              This causes a ValueError at runtime.
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
private int countElements(ExprList exprList) { 
    result = count(exprList.getAnItem()) 
}

// Detects mismatched assignments between LHS variables and RHS sequences
predicate assignmentMismatch(Assign assignment, int lhsCount, int rhsCount, Location errorLocation, string sequenceType) {
    exists(ExprList lhsElements, ExprList rhsElements |
        // Check for tuple/list unpacking on LHS
        (assignment.getATarget().(Tuple).getElts() = lhsElements or
         assignment.getATarget().(List).getElts() = lhsElements) and
        // Check for explicit tuple/list on RHS
        (assignment.getValue().(Tuple).getElts() = rhsElements and sequenceType = "tuple" or
         assignment.getValue().(List).getElts() = rhsElements and sequenceType = "list") and
        // Get location of RHS sequence
        errorLocation = assignment.getValue().getLocation() and
        // Calculate element counts
        lhsCount = countElements(lhsElements) and
        rhsCount = countElements(rhsElements) and
        // Verify mismatch and no starred expressions
        lhsCount != rhsCount and
        not exists(Starred s | lhsElements.getAnItem() = s or rhsElements.getAnItem() = s)
    )
    or
    // Handle cases where RHS points to a tuple value
    exists(ExprList lhsElements, TupleValue rhsTuple, AstNode valueOrigin |
        // Check for tuple/list unpacking on LHS
        (assignment.getATarget().(Tuple).getElts() = lhsElements or
         assignment.getATarget().(List).getElts() = lhsElements) and
        // Check if RHS points to a tuple value
        assignment.getValue().pointsTo(rhsTuple, valueOrigin) and
        // Get location of the value origin
        errorLocation = valueOrigin.getLocation() and
        // Calculate element counts
        lhsCount = countElements(lhsElements) and
        rhsCount = rhsTuple.length() and
        // Verify mismatch and no starred expressions on LHS
        lhsCount != rhsCount and
        not lhsElements.getAnItem() instanceof Starred and
        sequenceType = "tuple"  // Only tuples can be resolved through pointsTo
    )
}

// Find all assignments with mismatched element counts
from Assign assignment, int lhsCount, int rhsCount, Location errorLocation, string sequenceType
where assignmentMismatch(assignment, lhsCount, rhsCount, errorLocation, sequenceType)
select assignment,
    "Left hand side has " + lhsCount +
    " variables, but right hand side is a $@ with " + rhsCount + " elements.", 
    errorLocation, sequenceType