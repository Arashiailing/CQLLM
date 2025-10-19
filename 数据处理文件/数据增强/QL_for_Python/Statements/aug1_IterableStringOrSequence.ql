/**
 * @name Iterable can be either a string or a sequence
 * @description Detects loops that iterate over both string and sequence types, 
 * which can cause hard-to-diagnose runtime errors due to inconsistent iteration behavior
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
  Value stringVal, 
  Value sequenceVal, 
  ControlFlowNode sequenceOrigin,
  ControlFlowNode stringOrigin
where 
  // Ensure iterator node points to both string and sequence values
  targetLoop.getIter().getAFlowNode() = iteratorNode and
  iteratorNode.pointsTo(stringVal, stringOrigin) and
  iteratorNode.pointsTo(sequenceVal, sequenceOrigin) and
  
  // Validate string and sequence types
  has_string_type(stringVal) and
  sequenceVal.getClass().isIterable() and
  not has_string_type(sequenceVal) and
  
  // Exclude test code scenarios
  not sequenceOrigin.getScope().getScope*() instanceof TestScope and
  not stringOrigin.getScope().getScope*() instanceof TestScope
select targetLoop,
  "Iteration over $@, of class " + sequenceVal.getClass().getName() + 
  ", may also iterate over $@.",
  sequenceOrigin, "sequence", stringOrigin, "string"