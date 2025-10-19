/**
 * @name Iterable can be either a string or a sequence
 * @description Detects loops iterating over both string and sequence types,
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

// Helper predicate to identify string types (str or Python 2 unicode)
predicate is_string_type(Value value) {
  value.getClass() = ClassValue::str() 
  or 
  value.getClass() = ClassValue::unicode() and major_version() = 2
}

from 
  For targetLoop, 
  ControlFlowNode iteratorNode, 
  Value stringVal, 
  Value sequenceVal, 
  ControlFlowNode sequenceSource,
  ControlFlowNode stringSource
where 
  // Verify iterator node connects to both string and sequence values
  targetLoop.getIter().getAFlowNode() = iteratorNode and
  iteratorNode.pointsTo(stringVal, stringSource) and
  iteratorNode.pointsTo(sequenceVal, sequenceSource) and
  
  // Validate type characteristics
  is_string_type(stringVal) and
  sequenceVal.getClass().isIterable() and
  not is_string_type(sequenceVal) and
  
  // Exclude test-related code paths
  not sequenceSource.getScope().getScope*() instanceof TestScope and
  not stringSource.getScope().getScope*() instanceof TestScope
select targetLoop,
  "Iteration over $@, of class " + sequenceVal.getClass().getName() + 
  ", may also iterate over $@.",
  sequenceSource, "sequence", stringSource, "string"