/**
 * @name Mixed iterable types: string and sequence
 * @description Detects loops that iterate over both string and sequence types simultaneously,
 *              which can cause unexpected behavior and runtime errors.
 * @kind problem
 * @tags reliability
 *       maintainability
 *       non-local
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/iteration-string-and-sequence
 */

import python
import semmle.python.filters.Tests

// Helper predicate to determine if a value is of string type (str or unicode in Python 2)
predicate isStringType(Value val) {
  val.getClass() = ClassValue::str()
  or
  val.getClass() = ClassValue::unicode() and major_version() = 2
}

from
  For loopStmt, ControlFlowNode iterExprNode, 
  Value strVal, Value seqVal, 
  ControlFlowNode seqOriginNode, ControlFlowNode strOriginNode
where
  // Connect the loop to its iterator expression in the control flow graph
  loopStmt.getIter().getAFlowNode() = iterExprNode and
  
  // The iterator expression must point to both a string and a sequence value
  iterExprNode.pointsTo(strVal, strOriginNode) and
  iterExprNode.pointsTo(seqVal, seqOriginNode) and
  
  // Type validation: one value must be a string, the other must be iterable but not a string
  isStringType(strVal) and
  seqVal.getClass().isIterable() and
  not isStringType(seqVal) and
  
  // Exclude test code to minimize false positives
  not seqOriginNode.getScope().getScope*() instanceof TestScope and
  not strOriginNode.getScope().getScope*() instanceof TestScope
select loopStmt,
  "Iteration over $@, of class " + seqVal.getClass().getName() + ", may also iterate over $@.",
  seqOriginNode, "sequence", strOriginNode, "string"