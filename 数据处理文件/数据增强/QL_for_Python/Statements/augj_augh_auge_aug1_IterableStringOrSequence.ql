/**
 * @name Iteration over both string and sequence types
 * @description Identifies for-loops that iterate over values which can be either strings or sequences (like lists).
 * This pattern is problematic because strings iterate over individual characters while sequences iterate over elements,
 * leading to inconsistent behavior and potential runtime errors.
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

// Determines if a value is of string type (str or Python 2 unicode)
predicate isStringValueType(Value value) {
  value.getClass() = ClassValue::str() 
  or 
  value.getClass() = ClassValue::unicode() and major_version() = 2
}

from 
  For problematicLoop, 
  ControlFlowNode iterNode, 
  Value stringValue, 
  Value sequenceValue, 
  ControlFlowNode sequenceOrigin,
  ControlFlowNode stringOrigin
where 
  // The iterator node in the for-loop points to both string and sequence values
  problematicLoop.getIter().getAFlowNode() = iterNode and
  iterNode.pointsTo(stringValue, stringOrigin) and
  iterNode.pointsTo(sequenceValue, sequenceOrigin) and
  
  // Type validation: one value is a string, the other is a non-string iterable
  isStringValueType(stringValue) and
  sequenceValue.getClass().isIterable() and
  not isStringValueType(sequenceValue) and
  
  // Exclude test code from the analysis
  not sequenceOrigin.getScope().getScope*() instanceof TestScope and
  not stringOrigin.getScope().getScope*() instanceof TestScope
select problematicLoop,
  "Iteration over $@, of class " + sequenceValue.getClass().getName() + 
  ", may also iterate over $@.",
  sequenceOrigin, "sequence", stringOrigin, "string"