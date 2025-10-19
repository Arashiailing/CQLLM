/**
 * @name Ambiguous Iterable: String or Sequence
 * @description Detects loops where the iterator expression can resolve to both 
 * string and sequence types. This ambiguity leads to inconsistent iteration behavior 
 * as strings yield individual characters while sequences yield elements, potentially 
 * causing runtime errors that are challenging to debug.
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

// Helper predicate to determine if a value represents a string type (str or Python 2 unicode)
predicate isStringType(Value stringValue) {
  stringValue.getClass() = ClassValue::str() 
  or 
  stringValue.getClass() = ClassValue::unicode() and major_version() = 2
}

// Predicate to check if a value is a non-string iterable type
predicate isNonStringIterable(Value value) {
  value.getClass().isIterable() and
  not isStringType(value)
}

// Predicate to exclude test code from analysis
predicate isNotInTestScope(ControlFlowNode node) {
  not node.getScope().getScope*() instanceof TestScope
}

from 
  For loopStmt, 
  ControlFlowNode iterExprNode, 
  Value stringTypeValue, 
  Value sequenceTypeValue, 
  ControlFlowNode sequenceSourceNode,
  ControlFlowNode stringSourceNode
where 
  // The iterator expression in the loop points to both string and sequence values
  loopStmt.getIter().getAFlowNode() = iterExprNode and
  iterExprNode.pointsTo(stringTypeValue, stringSourceNode) and
  iterExprNode.pointsTo(sequenceTypeValue, sequenceSourceNode) and
  
  // Verify one value is a string type and the other is a non-string iterable
  isStringType(stringTypeValue) and
  isNonStringIterable(sequenceTypeValue) and
  
  // Exclude test code from analysis results
  isNotInTestScope(sequenceSourceNode) and
  isNotInTestScope(stringSourceNode)
select loopStmt,
  "Iteration over $@, of class " + sequenceTypeValue.getClass().getName() + 
  ", may also iterate over $@.",
  sequenceSourceNode, "sequence", stringSourceNode, "string"