/**
 * @name Mismatch in multiple assignment
 * @description Detects assignments where the number of variables on the left side 
 *              doesn't match the number of elements in the container on the right side,
 *              which will cause a runtime exception.
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

// Compute the total count of elements within an expression list
private int calculateExpressionListSize(ExprList expressionList) { 
  result = count(expressionList.getAnItem()) 
}

// Detect assignments where the number of elements on the left-hand side 
// doesn't match the number of elements in the container on the right-hand side
predicate containsMismatchedAssignment(Assign assignment, int leftElementCount, int rightElementCount, Location errorLocation, string containerType) {
  exists(ExprList leftHandExprList | 
    // Extract elements from LHS tuple or list
    (
      assignment.getATarget().(Tuple).getElts() = leftHandExprList or
      assignment.getATarget().(List).getElts() = leftHandExprList
    ) and
    // Handle two distinct mismatch scenarios
    (
      // Scenario 1: Direct container on RHS
      exists(ExprList rightHandExprList |
        (
          assignment.getValue().(Tuple).getElts() = rightHandExprList and containerType = "tuple"
          or
          assignment.getValue().(List).getElts() = rightHandExprList and containerType = "list"
        ) and
        errorLocation = assignment.getValue().getLocation() and
        leftElementCount = calculateExpressionListSize(leftHandExprList) and
        rightElementCount = calculateExpressionListSize(rightHandExprList) and
        leftElementCount != rightElementCount and
        // Verify absence of starred expressions on both sides
        not exists(Starred starredExpr | 
          leftHandExprList.getAnItem() = starredExpr or rightHandExprList.getAnItem() = starredExpr
        )
      )
      or
      // Scenario 2: Tuple value reference on RHS
      exists(TupleValue tupleVal, AstNode sourceNode |
        assignment.getValue().pointsTo(tupleVal, sourceNode) and
        containerType = "tuple" and
        errorLocation = sourceNode.getLocation() and
        leftElementCount = calculateExpressionListSize(leftHandExprList) and
        rightElementCount = tupleVal.length() and
        leftElementCount != rightElementCount and
        // Confirm no starred expression on LHS
        not leftHandExprList.getAnItem() instanceof Starred
      )
    )
  )
}

// Identify all assignments with element count mismatches
from Assign assignment, int leftElementCount, int rightElementCount, Location errorLocation, string containerType
where containsMismatchedAssignment(assignment, leftElementCount, rightElementCount, errorLocation, containerType)
select assignment,
  "Left hand side of assignment contains " + leftElementCount +
    " variables, but right hand side is a $@ of length " + rightElementCount + ".", 
  errorLocation, containerType