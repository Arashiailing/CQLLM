/**
 * @name Mismatch in multiple assignment
 * @description Assigning multiple variables without ensuring that you define a
 *              value for each variable causes an exception at runtime.
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

// Calculate the number of elements in an expression list
private int countElements(ExprList exprList) { 
  result = count(exprList.getAnItem()) 
}

// Detect mismatch between assignment targets and values when both sides are explicit sequences
predicate explicitSequenceMismatch(Assign assignment, int targetCount, int valueCount, Location errorLocation, string sequenceKind) {
  exists(ExprList targetExprs, ExprList valueExprs |
    (
      // Check if assignment target is a tuple or list
      assignment.getATarget().(Tuple).getElts() = targetExprs or
      assignment.getATarget().(List).getElts() = targetExprs
    ) and
    (
      // Check if assignment value is a tuple or list
      assignment.getValue().(Tuple).getElts() = valueExprs and sequenceKind = "tuple"
      or
      assignment.getValue().(List).getElts() = valueExprs and sequenceKind = "list"
    ) and
    // Get error location from the value expression
    errorLocation = assignment.getValue().getLocation() and
    // Count elements on both sides
    targetCount = countElements(targetExprs) and
    valueCount = countElements(valueExprs) and
    // Verify element count mismatch
    targetCount != valueCount and
    // Ensure no starred expressions are used
    not exists(Starred s | targetExprs.getAnItem() = s or valueExprs.getAnItem() = s)
  )
}

// Detect mismatch when assignment value points to a tuple value
predicate tupleValueMismatch(Assign assignment, int targetCount, int valueCount, Location errorLocation) {
  exists(ExprList targetExprs, TupleValue tupleValue, AstNode sourceNode |
    (
      // Check if assignment target is a tuple or list
      assignment.getATarget().(Tuple).getElts() = targetExprs or
      assignment.getATarget().(List).getElts() = targetExprs
    ) and
    // Check if assignment value points to a tuple
    assignment.getValue().pointsTo(tupleValue, sourceNode) and
    // Get error location from the source node
    errorLocation = sourceNode.getLocation() and
    // Count elements on both sides
    targetCount = countElements(targetExprs) and
    valueCount = tupleValue.length() and
    // Verify element count mismatch
    targetCount != valueCount and
    // Ensure no starred expressions in targets
    not targetExprs.getAnItem() instanceof Starred
  )
}

// Find all assignments with mismatched element counts
from Assign assignment, int targetCount, int valueCount, Location errorLocation, string sequenceKind
where
  // Check for explicit sequence mismatches
  explicitSequenceMismatch(assignment, targetCount, valueCount, errorLocation, sequenceKind)
  or
  // Check for tuple value mismatches
  tupleValueMismatch(assignment, targetCount, valueCount, errorLocation) and
  sequenceKind = "tuple"
select assignment,
  // Generate problem description
  "Left hand side of assignment contains " + targetCount +
    " variables, but right hand side is a $@ of length " + valueCount + ".", errorLocation, sequenceKind