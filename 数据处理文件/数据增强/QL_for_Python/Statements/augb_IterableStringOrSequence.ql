/**
 * @name Iterable can be either a string or a sequence
 * @description Detects loops that iterate over both string and sequence types,
 *              which can cause unexpected behavior due to different iteration semantics.
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

// Helper predicate to identify string-type values
predicate is_string_type(Value val) {
  val.getClass() = ClassValue::str() 
  or 
  val.getClass() = ClassValue::unicode() and major_version() = 2
}

from
  For targetLoop, 
  ControlFlowNode iteratorNode, 
  Value stringValue, 
  Value sequenceValue,
  ControlFlowNode sequenceOrigin,
  ControlFlowNode stringOrigin
where
  // Identify the iterator node in the loop
  targetLoop.getIter().getAFlowNode() = iteratorNode and
  
  // Iterator points to both string and sequence values
  iteratorNode.pointsTo(stringValue, stringOrigin) and
  iteratorNode.pointsTo(sequenceValue, sequenceOrigin) and
  
  // Type validation: string must be string-type, sequence must be non-string iterable
  is_string_type(stringValue) and
  sequenceValue.getClass().isIterable() and
  not is_string_type(sequenceValue) and
  
  // Exclude test code occurrences
  not sequenceOrigin.getScope().getScope*() instanceof TestScope and
  not stringOrigin.getScope().getScope*() instanceof TestScope
select targetLoop,
  "Iteration over $@, of class " + sequenceValue.getClass().getName() + 
  ", may also iterate over $@.",
  sequenceOrigin, "sequence", stringOrigin, "string"