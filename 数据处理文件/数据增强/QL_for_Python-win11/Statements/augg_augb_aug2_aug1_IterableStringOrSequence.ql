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
  For loopNode, 
  ControlFlowNode iterNode, 
  Value strValue, 
  Value seqValue, 
  ControlFlowNode seqSource,
  ControlFlowNode strSource
where 
  // Connect iterator node to both string and sequence values
  loopNode.getIter().getAFlowNode() = iterNode and
  iterNode.pointsTo(strValue, strSource) and
  iterNode.pointsTo(seqValue, seqSource) and
  
  // Validate type characteristics
  is_string_type(strValue) and
  seqValue.getClass().isIterable() and
  not is_string_type(seqValue) and
  
  // Exclude test-related code paths
  not seqSource.getScope().getScope*() instanceof TestScope and
  not strSource.getScope().getScope*() instanceof TestScope
select loopNode,
  "Iteration over $@, of class " + seqValue.getClass().getName() + 
  ", may also iterate over $@.",
  seqSource, "sequence", strSource, "string"