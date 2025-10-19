/**
 * @name Iterable can be either a string or a sequence
 * @description Identifies loops that iterate over both string and sequence types,
 *              which may lead to unexpected behavior due to differing iteration semantics.
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
  For loopNode, 
  ControlFlowNode iterNode, 
  Value strVal, 
  Value seqVal,
  ControlFlowNode seqOrigin,
  ControlFlowNode strOrigin
where
  // Identify the iterator node in the loop
  loopNode.getIter().getAFlowNode() = iterNode and
  
  // Iterator points to both string and sequence values
  iterNode.pointsTo(strVal, strOrigin) and
  iterNode.pointsTo(seqVal, seqOrigin) and
  
  // Type validation: string must be string-type, sequence must be non-string iterable
  is_string_type(strVal) and
  seqVal.getClass().isIterable() and
  not is_string_type(seqVal) and
  
  // Exclude test code occurrences
  not seqOrigin.getScope().getScope*() instanceof TestScope and
  not strOrigin.getScope().getScope*() instanceof TestScope
select loopNode,
  "Iteration over $@, of class " + seqVal.getClass().getName() + 
  ", may also iterate over $@.",
  seqOrigin, "sequence", strOrigin, "string"