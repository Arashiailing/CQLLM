/**
 * @name Iterable can be either a string or a sequence
 * @description Identifies loops that iterate over both string and sequence types,
 *              which can lead to unexpected behavior due to differing iteration semantics.
 *              This occurs when the same iterator can reference both string and sequence types.
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
  For problematicLoop, 
  ControlFlowNode iterExprNode, 
  Value strValue, 
  Value seqValue,
  ControlFlowNode seqOrigin,
  ControlFlowNode strOrigin
where
  // Identify the iterator expression in the loop
  problematicLoop.getIter().getAFlowNode() = iterExprNode and
  
  // Iterator expression can point to both string and sequence values
  iterExprNode.pointsTo(strValue, strOrigin) and
  iterExprNode.pointsTo(seqValue, seqOrigin) and
  
  // Type validation: ensure one is string and the other is a non-string iterable
  is_string_type(strValue) and
  seqValue.getClass().isIterable() and
  not is_string_type(seqValue) and
  
  // Exclude occurrences in test code
  not seqOrigin.getScope().getScope*() instanceof TestScope and
  not strOrigin.getScope().getScope*() instanceof TestScope
select problematicLoop,
  "Iteration over $@, of class " + seqValue.getClass().getName() + 
  ", may also iterate over $@.",
  seqOrigin, "sequence", strOrigin, "string"