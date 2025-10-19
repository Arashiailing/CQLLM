/**
 * @name Iteration over both string and sequence types
 * @description Detects for-loops that iterate over values which can be either strings or sequences (like lists).
 * This pattern is problematic because strings iterate over individual characters while sequences iterate over elements,
 * leading to inconsistent behavior and potential runtime errors.
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

// Checks if a value is of string type (str or Python 2 unicode)
predicate isStringType(Value value) {
  value.getClass() = ClassValue::str() 
  or 
  value.getClass() = ClassValue::unicode() and major_version() = 2
}

from 
  For problematicForLoop, 
  ControlFlowNode iteratorNode, 
  Value strValue, 
  Value seqValue, 
  ControlFlowNode seqSource,
  ControlFlowNode strSource
where 
  // The iterator node in the for-loop points to both string and sequence values
  problematicForLoop.getIter().getAFlowNode() = iteratorNode and
  iteratorNode.pointsTo(strValue, strSource) and
  iteratorNode.pointsTo(seqValue, seqSource) and
  
  // Type validation: one value is a string, the other is a non-string iterable
  isStringType(strValue) and
  seqValue.getClass().isIterable() and
  not isStringType(seqValue) and
  
  // Exclude test code from the analysis
  not seqSource.getScope().getScope*() instanceof TestScope and
  not strSource.getScope().getScope*() instanceof TestScope
select problematicForLoop,
  "Iteration over $@, of class " + seqValue.getClass().getName() + 
  ", may also iterate over $@.",
  seqSource, "sequence", strSource, "string"