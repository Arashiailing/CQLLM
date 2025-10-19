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
predicate isStringType(Value targetValue) {
  targetValue.getClass() = ClassValue::str() 
  or 
  targetValue.getClass() = ClassValue::unicode() and major_version() = 2
}

from 
  For problematicLoop, 
  ControlFlowNode iteratorNode, 
  Value strValue, 
  Value seqValue, 
  ControlFlowNode sequenceOrigin,
  ControlFlowNode stringOrigin
where 
  // Ensure iterator node points to both string and sequence values
  problematicLoop.getIter().getAFlowNode() = iteratorNode and
  iteratorNode.pointsTo(strValue, stringOrigin) and
  iteratorNode.pointsTo(seqValue, sequenceOrigin) and
  
  // Validate string and sequence types
  isStringType(strValue) and
  seqValue.getClass().isIterable() and
  not isStringType(seqValue) and
  
  // Exclude test code scenarios
  not sequenceOrigin.getScope().getScope*() instanceof TestScope and
  not stringOrigin.getScope().getScope*() instanceof TestScope
select problematicLoop,
  "Iteration over $@, of class " + seqValue.getClass().getName() + 
  ", may also iterate over $@.",
  sequenceOrigin, "sequence", stringOrigin, "string"