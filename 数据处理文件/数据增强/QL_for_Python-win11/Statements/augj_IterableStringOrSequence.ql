/**
 * @name Ambiguous iteration over string or sequence
 * @description Detects loops where the iterator may refer to either a string or a sequence (non-string iterable),
 *              which can lead to unexpected behavior and hard-to-diagnose errors.
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

// Helper predicate to determine if a value is of string type
predicate has_string_type(Value value) {
  value.getClass() = ClassValue::str()
  or
  value.getClass() = ClassValue::unicode() and major_version() = 2
}

from
  For targetLoop, ControlFlowNode iteratorNode, Value stringValue, Value sequenceValue,
  ControlFlowNode sequenceOrigin, ControlFlowNode stringOrigin
where
  // Establish relationship between loop and its iterator
  targetLoop.getIter().getAFlowNode() = iteratorNode and
  
  // Iterator points to both string and sequence values
  iteratorNode.pointsTo(stringValue, stringOrigin) and
  iteratorNode.pointsTo(sequenceValue, sequenceOrigin) and
  
  // Verify string type characteristics
  has_string_type(stringValue) and
  
  // Verify sequence type characteristics (iterable but not string)
  sequenceValue.getClass().isIterable() and
  not has_string_type(sequenceValue) and
  
  // Exclude occurrences from test code
  not sequenceOrigin.getScope().getScope*() instanceof TestScope and
  not stringOrigin.getScope().getScope*() instanceof TestScope
select targetLoop,
  "Iteration over $@, of class " + sequenceValue.getClass().getName() + ", may also iterate over $@.",
  sequenceOrigin, "sequence", stringOrigin, "string"