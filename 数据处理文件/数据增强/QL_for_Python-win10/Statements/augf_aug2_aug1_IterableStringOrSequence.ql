/**
 * @name Iterable can be either a string or a sequence
 * @description Detects for-loops that iterate over both string and sequence types,
 * potentially causing runtime errors due to inconsistent iteration behavior
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

/**
 * Checks if a value represents a string type
 * (either str in Python 3 or str/unicode in Python 2)
 */
predicate isStringType(Value value) {
  value.getClass() = ClassValue::str() 
  or 
  value.getClass() = ClassValue::unicode() and major_version() = 2
}

from 
  For forLoop, 
  ControlFlowNode iteratorNode, 
  Value stringValue, 
  Value sequenceValue, 
  ControlFlowNode sequenceOrigin,
  ControlFlowNode stringOrigin
where 
  // Iterator node connection
  forLoop.getIter().getAFlowNode() = iteratorNode and
  
  // Iterator node points to both string and sequence values
  iteratorNode.pointsTo(stringValue, stringOrigin) and
  iteratorNode.pointsTo(sequenceValue, sequenceOrigin) and
  
  // Type validation - one is string, other is iterable (but not string)
  isStringType(stringValue) and
  sequenceValue.getClass().isIterable() and
  not isStringType(sequenceValue) and
  
  // Exclude test code to reduce false positives
  not sequenceOrigin.getScope().getScope*() instanceof TestScope and
  not stringOrigin.getScope().getScope*() instanceof TestScope
select forLoop,
  "Iteration over $@, of class " + sequenceValue.getClass().getName() + 
  ", may also iterate over $@.",
  sequenceOrigin, "sequence", stringOrigin, "string"