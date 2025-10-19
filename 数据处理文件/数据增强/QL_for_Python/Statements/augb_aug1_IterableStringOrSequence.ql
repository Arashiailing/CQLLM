/**
 * @name Iterable can be either a string or a sequence
 * @description Detects loops that iterate over both string and sequence types. 
 * This can lead to runtime errors because strings iterate over characters while 
 * sequences iterate over elements, causing inconsistent behavior that's hard to diagnose.
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

// Helper predicate to check if a value is a string type (str or Python 2 unicode)
predicate isStringType(Value value) {
  value.getClass() = ClassValue::str() 
  or 
  value.getClass() = ClassValue::unicode() and major_version() = 2
}

from 
  For loopNode, 
  ControlFlowNode iterExprNode, 
  Value stringValue, 
  Value sequenceValue, 
  ControlFlowNode sequenceSourceNode,
  ControlFlowNode stringSourceNode
where 
  // The loop's iterator expression can point to both string and sequence values
  loopNode.getIter().getAFlowNode() = iterExprNode and
  iterExprNode.pointsTo(stringValue, stringSourceNode) and
  iterExprNode.pointsTo(sequenceValue, sequenceSourceNode) and
  
  // Validate that one value is a string type and the other is a non-string iterable
  isStringType(stringValue) and
  sequenceValue.getClass().isIterable() and
  not isStringType(sequenceValue) and
  
  // Exclude test code from analysis
  not sequenceSourceNode.getScope().getScope*() instanceof TestScope and
  not stringSourceNode.getScope().getScope*() instanceof TestScope
select loopNode,
  "Iteration over $@, of class " + sequenceValue.getClass().getName() + 
  ", may also iterate over $@.",
  sequenceSourceNode, "sequence", stringSourceNode, "string"