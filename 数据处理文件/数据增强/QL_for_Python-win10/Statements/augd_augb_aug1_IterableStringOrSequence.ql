/**
 * @name Iterable can be either a string or a sequence
 * @description Identifies loops where the iterator expression may resolve to both 
 * string and sequence types. This creates inconsistent iteration behavior since 
 * strings yield characters while sequences yield elements, potentially causing 
 * runtime errors that are difficult to diagnose.
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
predicate isStringType(Value strVal) {
  strVal.getClass() = ClassValue::str() 
  or 
  strVal.getClass() = ClassValue::unicode() and major_version() = 2
}

from 
  For targetLoop, 
  ControlFlowNode iteratorExprNode, 
  Value strValue, 
  Value seqValue, 
  ControlFlowNode seqSourceNode,
  ControlFlowNode strSourceNode
where 
  // Ensure the iterator expression points to both string and sequence values
  targetLoop.getIter().getAFlowNode() = iteratorExprNode and
  iteratorExprNode.pointsTo(strValue, strSourceNode) and
  iteratorExprNode.pointsTo(seqValue, seqSourceNode) and
  
  // Verify one value is a string type and the other is a non-string iterable
  isStringType(strValue) and
  seqValue.getClass().isIterable() and
  not isStringType(seqValue) and
  
  // Exclude test code from analysis results
  not seqSourceNode.getScope().getScope*() instanceof TestScope and
  not strSourceNode.getScope().getScope*() instanceof TestScope
select targetLoop,
  "Iteration over $@, of class " + seqValue.getClass().getName() + 
  ", may also iterate over $@.",
  seqSourceNode, "sequence", strSourceNode, "string"