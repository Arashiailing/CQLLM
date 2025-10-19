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

// Predicate to determine if a value represents a string type (str or Python 2 unicode)
predicate is_string_type(Value value) {
  value.getClass() = ClassValue::str() 
  or 
  value.getClass() = ClassValue::unicode() and major_version() = 2
}

// Main analysis to detect problematic iteration patterns
from 
  For loopStmt, 
  ControlFlowNode iterNode, 
  Value strValue, 
  Value seqValue, 
  ControlFlowNode seqSource,
  ControlFlowNode strSource
where 
  // Ensure the iterator node in the loop points to both string and sequence values
  loopStmt.getIter().getAFlowNode() = iterNode and
  iterNode.pointsTo(strValue, strSource) and
  iterNode.pointsTo(seqValue, seqSource) and
  
  // Type validation: one value must be a string, the other a non-string iterable
  is_string_type(strValue) and
  seqValue.getClass().isIterable() and
  not is_string_type(seqValue) and
  
  // Exclude test code from analysis results
  not seqSource.getScope().getScope*() instanceof TestScope and
  not strSource.getScope().getScope*() instanceof TestScope
select loopStmt,
  "Iteration over $@, of class " + seqValue.getClass().getName() + 
  ", may also iterate over $@.",
  seqSource, "sequence", strSource, "string"