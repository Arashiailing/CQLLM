/**
 * @name Iterable can be either a string or a sequence
 * @description Detects loops that iterate over both string and sequence types,
 *              which may cause unexpected behavior due to different iteration semantics.
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

// Helper predicate to identify string-type values
predicate is_string_type(Value val) {
  val.getClass() = ClassValue::str() 
  or 
  val.getClass() = ClassValue::unicode() and major_version() = 2
}

from
  For targetLoop, 
  ControlFlowNode iteratorNode, 
  Value stringVal, 
  Value sequenceVal,
  ControlFlowNode sequenceSource,
  ControlFlowNode stringSource
where
  // Establish relationship between loop and its iterator
  targetLoop.getIter().getAFlowNode() = iteratorNode and
  
  // Iterator references both string and sequence values
  iteratorNode.pointsTo(stringVal, stringSource) and
  iteratorNode.pointsTo(sequenceVal, sequenceSource) and
  
  // Validate types: string must be string-type, sequence must be non-string iterable
  is_string_type(stringVal) and
  sequenceVal.getClass().isIterable() and
  not is_string_type(sequenceVal) and
  
  // Exclude occurrences in test code
  not sequenceSource.getScope().getScope*() instanceof TestScope and
  not stringSource.getScope().getScope*() instanceof TestScope
select targetLoop,
  "Iteration over $@, of class " + sequenceVal.getClass().getName() + 
  ", may also iterate over $@.",
  sequenceSource, "sequence", stringSource, "string"