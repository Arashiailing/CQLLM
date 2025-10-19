/**
 * @name Mixed iterable types: string and sequence
 * @description Simultaneous iteration over both string and sequence types within the same loop can lead to subtle runtime errors.
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

// Helper predicate to identify values of string type
predicate is_string_type(Value val) {
  val.getClass() = ClassValue::str()
  or
  val.getClass() = ClassValue::unicode() and major_version() = 2
}

from
  For targetLoop, ControlFlowNode iteratorNode, 
  Value stringValue, Value sequenceValue, 
  ControlFlowNode sequenceOrigin, ControlFlowNode stringOrigin
where
  // Establish relationship between loop and its iterator
  targetLoop.getIter().getAFlowNode() = iteratorNode and
  
  // Verify iterator points to both string and sequence values
  iteratorNode.pointsTo(stringValue, stringOrigin) and
  iteratorNode.pointsTo(sequenceValue, sequenceOrigin) and
  
  // Validate value types: one must be string, the other must be iterable but not string
  is_string_type(stringValue) and
  sequenceValue.getClass().isIterable() and
  not is_string_type(sequenceValue) and
  
  // Filter out test code to reduce false positives
  not sequenceOrigin.getScope().getScope*() instanceof TestScope and
  not stringOrigin.getScope().getScope*() instanceof TestScope
select targetLoop,
  "Iteration over $@, of class " + sequenceValue.getClass().getName() + ", may also iterate over $@.",
  sequenceOrigin, "sequence", stringOrigin, "string"