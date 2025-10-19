/**
 * @name Iterable can be either a string or a sequence
 * @description Detects loops that iterate over both string and sequence types,
 * which may lead to runtime errors due to inconsistent iteration behavior.
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

// Check if a value represents a string type (str or Python 2 unicode)
predicate is_string_type(Value value) {
  value.getClass() = ClassValue::str() 
  or 
  value.getClass() = ClassValue::unicode() and major_version() = 2
}

from 
  For targetLoop, 
  ControlFlowNode iteratorNode, 
  Value stringValue, 
  Value sequenceValue, 
  ControlFlowNode sequenceOrigin,
  ControlFlowNode stringOrigin
where 
  // Extract the iterator node from the loop structure
  targetLoop.getIter().getAFlowNode() = iteratorNode and
  
  // Verify that the iterator node points to both string and sequence values
  iteratorNode.pointsTo(stringValue, stringOrigin) and
  iteratorNode.pointsTo(sequenceValue, sequenceOrigin) and
  
  // Ensure type compatibility: one is string and the other is a non-string iterable
  is_string_type(stringValue) and
  sequenceValue.getClass().isIterable() and
  not is_string_type(sequenceValue) and
  
  // Exclude test code from the analysis to reduce false positives
  not stringOrigin.getScope().getScope*() instanceof TestScope and
  not sequenceOrigin.getScope().getScope*() instanceof TestScope
select targetLoop,
  "Iteration over $@, of class " + sequenceValue.getClass().getName() + 
  ", may also iterate over $@.",
  sequenceOrigin, "sequence", stringOrigin, "string"