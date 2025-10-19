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

// Helper to determine if a value represents string types (str or Python 2 unicode)
predicate is_string_type(Value value) {
  value.getClass() = ClassValue::str() 
  or 
  value.getClass() = ClassValue::unicode() and major_version() = 2
}

from 
  For iterationLoop, 
  ControlFlowNode iterableNode, 
  Value strValue, 
  Value seqValue, 
  ControlFlowNode seqSource,
  ControlFlowNode strSource
where 
  // Link iterator node to the loop's iterable expression
  iterationLoop.getIter().getAFlowNode() = iterableNode and
  
  // Trace data flow to both string and sequence values
  iterableNode.pointsTo(strValue, strSource) and
  iterableNode.pointsTo(seqValue, seqSource) and
  
  // Validate type characteristics
  is_string_type(strValue) and
  seqValue.getClass().isIterable() and
  not is_string_type(seqValue) and
  
  // Exclude test-related code paths
  not seqSource.getScope().getScope*() instanceof TestScope and
  not strSource.getScope().getScope*() instanceof TestScope
select iterationLoop,
  "Iteration over $@, of class " + seqValue.getClass().getName() + 
  ", may also iterate over $@.",
  seqSource, "sequence", strSource, "string"