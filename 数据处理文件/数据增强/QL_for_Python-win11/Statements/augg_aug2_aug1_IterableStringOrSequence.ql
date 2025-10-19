/**
 * @name Iterable can be either a string or a sequence
 * @description Identifies loops that iterate over both string and sequence types,
 * which may lead to runtime errors due to inconsistent iteration behavior
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

// Predicate to check if a value represents string types (str or Python 2 unicode)
predicate is_string_type(Value value) {
  value.getClass() = ClassValue::str() 
  or 
  value.getClass() = ClassValue::unicode() and major_version() = 2
}

from 
  For loopStmt, 
  ControlFlowNode iteratorNode, 
  Value stringValue, 
  Value sequenceValue, 
  ControlFlowNode sequenceOrigin,
  ControlFlowNode stringOrigin
where 
  // Associate iterator node with the loop's iterable expression
  loopStmt.getIter().getAFlowNode() = iteratorNode and
  
  // Track data flow to both string and sequence values
  iteratorNode.pointsTo(stringValue, stringOrigin) and
  iteratorNode.pointsTo(sequenceValue, sequenceOrigin) and
  
  // Validate type characteristics
  is_string_type(stringValue) and
  sequenceValue.getClass().isIterable() and
  not is_string_type(sequenceValue) and
  
  // Exclude test-related code paths
  not sequenceOrigin.getScope().getScope*() instanceof TestScope and
  not stringOrigin.getScope().getScope*() instanceof TestScope
select loopStmt,
  "Iteration over $@, of class " + sequenceValue.getClass().getName() + 
  ", may also iterate over $@.",
  sequenceOrigin, "sequence", stringOrigin, "string"