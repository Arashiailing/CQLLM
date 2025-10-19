/**
 * @name Iterable can be either a string or a sequence
 * @description Identifies loops that iterate over both string and sequence types.
 * Such iteration patterns can cause runtime errors because strings yield characters
 * while sequences yield elements, leading to inconsistent behavior that is difficult to debug.
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

// Helper predicate to check if a value is a string type (str or Python 2 unicode)
predicate isStringType(Value value) {
  value.getClass() = ClassValue::str() 
  or 
  value.getClass() = ClassValue::unicode() and major_version() = 2
}

from 
  For iterationLoop, 
  ControlFlowNode iteratorExprNode, 
  Value strValue, 
  Value seqValue, 
  ControlFlowNode seqSourceNode,
  ControlFlowNode strSourceNode
where 
  // Establish relationship between loop and its iterator expression
  iterationLoop.getIter().getAFlowNode() = iteratorExprNode
  
  // Verify iterator expression points to both string and sequence values
  and iteratorExprNode.pointsTo(strValue, strSourceNode)
  and iteratorExprNode.pointsTo(seqValue, seqSourceNode)
  
  // Validate type constraints: one string and one non-string iterable
  and isStringType(strValue)
  and seqValue.getClass().isIterable()
  and not isStringType(seqValue)
  
  // Exclude test code from analysis scope
  and not seqSourceNode.getScope().getScope*() instanceof TestScope
  and not strSourceNode.getScope().getScope*() instanceof TestScope
select iterationLoop,
  "Iteration over $@, of class " + seqValue.getClass().getName() + 
  ", may also iterate over $@.",
  seqSourceNode, "sequence", strSourceNode, "string"