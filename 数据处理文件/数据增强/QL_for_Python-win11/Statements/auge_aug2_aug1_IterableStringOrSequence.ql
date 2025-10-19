/**
 * @name Iterable can be either a string or a sequence
 * @description Identifies loops that iterate over both string and sequence types,
 * which may lead to runtime errors due to inconsistent iteration behavior.
 * This occurs when the same iterator node can reference both string and non-string
 * iterable values, potentially causing unexpected runtime behavior.
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
  For targetLoop, 
  ControlFlowNode iteratorNode, 
  Value stringValue, 
  Value sequenceValue, 
  ControlFlowNode sequenceOrigin,
  ControlFlowNode stringOrigin
where 
  // Establish connection between loop and its iterator
  targetLoop.getIter().getAFlowNode() = iteratorNode
  
  // Verify iterator points to both string and sequence values
  and iteratorNode.pointsTo(stringValue, stringOrigin)
  and iteratorNode.pointsTo(sequenceValue, sequenceOrigin)
  
  // Validate string type for one value
  and has_string_type(stringValue)
  
  // Validate sequence type for the other value (non-string iterable)
  and sequenceValue.getClass().isIterable()
  and not has_string_type(sequenceValue)
  
  // Exclude test code scenarios
  and not sequenceOrigin.getScope().getScope*() instanceof TestScope
  and not stringOrigin.getScope().getScope*() instanceof TestScope
select targetLoop,
  "Iteration over $@, of class " + sequenceValue.getClass().getName() + 
  ", may also iterate over $@.",
  sequenceOrigin, "sequence", stringOrigin, "string"