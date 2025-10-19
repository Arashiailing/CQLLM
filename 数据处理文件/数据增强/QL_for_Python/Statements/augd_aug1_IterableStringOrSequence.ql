/**
 * @name Iterable can be either a string or a sequence
 * @description Identifies loops that iterate over both string and sequence types,
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

// Determines if a value represents a string type (str or Python 2 unicode)
predicate has_string_type(Value value) {
  value.getClass() = ClassValue::str() 
  or 
  value.getClass() = ClassValue::unicode() and major_version() = 2
}

from 
  For loopStmt, 
  ControlFlowNode iterNode, 
  Value strValue, 
  Value seqValue, 
  ControlFlowNode seqOrigin,
  ControlFlowNode strOrigin
where 
  // Extract iterator node from loop structure
  loopStmt.getIter().getAFlowNode() = iterNode and
  
  // Verify iterator points to both string and sequence values
  iterNode.pointsTo(strValue, strOrigin) and
  iterNode.pointsTo(seqValue, seqOrigin) and
  
  // Validate type compatibility: string + non-string iterable
  has_string_type(strValue) and
  seqValue.getClass().isIterable() and
  not has_string_type(seqValue) and
  
  // Exclude test code scenarios from analysis
  not strOrigin.getScope().getScope*() instanceof TestScope and
  not seqOrigin.getScope().getScope*() instanceof TestScope
select loopStmt,
  "Iteration over $@, of class " + seqValue.getClass().getName() + 
  ", may also iterate over $@.",
  seqOrigin, "sequence", strOrigin, "string"