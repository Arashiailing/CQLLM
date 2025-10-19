/**
 * @name Iteration over both string and sequence types
 * @description Identifies loops that iterate over values that can be either strings or sequences (like lists).
 * This can lead to runtime errors because strings iterate over characters while sequences iterate over elements,
 * causing inconsistent behavior.
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

// Determines if a value represents a string type (str or Python 2 unicode)
predicate has_string_type(Value value) {
  value.getClass() = ClassValue::str() 
  or 
  value.getClass() = ClassValue::unicode() and major_version() = 2
}

from 
  For problematicLoop, 
  ControlFlowNode iterNode, 
  Value stringValue, 
  Value sequenceValue, 
  ControlFlowNode sequenceSource,
  ControlFlowNode stringSource
where 
  // Ensure iterator node points to both string and sequence values
  problematicLoop.getIter().getAFlowNode() = iterNode and
  iterNode.pointsTo(stringValue, stringSource) and
  iterNode.pointsTo(sequenceValue, sequenceSource) and
  
  // Validate string and sequence types
  has_string_type(stringValue) and
  sequenceValue.getClass().isIterable() and
  not has_string_type(sequenceValue) and
  
  // Exclude test code scenarios
  not sequenceSource.getScope().getScope*() instanceof TestScope and
  not stringSource.getScope().getScope*() instanceof TestScope
select problematicLoop,
  "Iteration over $@, of class " + sequenceValue.getClass().getName() + 
  ", may also iterate over $@.",
  sequenceSource, "sequence", stringSource, "string"