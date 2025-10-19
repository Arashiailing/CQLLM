/**
 * @name Iterable can be either a string or a sequence
 * @description Detects loops that iterate over both string and sequence types, 
 * which may cause runtime errors due to inconsistent iteration behavior
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

// Predicate to identify string types (str or Python 2 unicode)
predicate is_string_type(Value value) {
  value.getClass() = ClassValue::str() 
  or 
  value.getClass() = ClassValue::unicode() and major_version() = 2
}

// Main analysis to detect problematic iteration patterns
from 
  For iterationLoop, 
  ControlFlowNode iteratorNode, 
  Value stringValue, 
  Value sequenceValue, 
  ControlFlowNode sequenceOrigin,
  ControlFlowNode stringOrigin
where 
  // Ensure iterator node connects to both string and sequence values
  iterationLoop.getIter().getAFlowNode() = iteratorNode and
  iteratorNode.pointsTo(stringValue, stringOrigin) and
  iteratorNode.pointsTo(sequenceValue, sequenceOrigin) and
  
  // Type validation: one value must be string, other must be non-string iterable
  is_string_type(stringValue) and
  sequenceValue.getClass().isIterable() and
  not is_string_type(sequenceValue) and
  
  // Exclude test code from analysis results
  not sequenceOrigin.getScope().getScope*() instanceof TestScope and
  not stringOrigin.getScope().getScope*() instanceof TestScope
select iterationLoop,
  "Iteration over $@, of class " + sequenceValue.getClass().getName() + 
  ", may also iterate over $@.",
  sequenceOrigin, "sequence", stringOrigin, "string"