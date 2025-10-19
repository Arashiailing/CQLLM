/**
 * @name Mixed iterable types in single iteration
 * @description Detects loops that may iterate over both strings and sequences,
 *              which can lead to unexpected behavior and hard-to-diagnose errors.
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

// Predicate to identify string-type values (including Python 2 unicode)
predicate isStringType(Value val) {
  val.getClass() = ClassValue::str()
  or
  val.getClass() = ClassValue::unicode() and major_version() = 2
}

from
  For currentLoop,  // Current loop being analyzed
  ControlFlowNode iterExprNode,  // Node representing the iterable expression
  Value strTypeValue,  // Value identified as string type
  Value seqTypeValue,  // Value identified as sequence type
  ControlFlowNode seqOriginNode,  // Origin of sequence value
  ControlFlowNode strOriginNode  // Origin of string value
where
  // Relationship between loop and its iterable expression
  currentLoop.getIter().getAFlowNode() = iterExprNode and
  
  // Data flow from iterable expression to both value types
  iterExprNode.pointsTo(strTypeValue, strOriginNode) and
  iterExprNode.pointsTo(seqTypeValue, seqOriginNode) and
  
  // Type validation: one string and one non-string iterable
  isStringType(strTypeValue) and
  seqTypeValue.getClass().isIterable() and
  not isStringType(seqTypeValue) and
  
  // Exclude test code from analysis scope
  not (seqOriginNode.getScope().getScope*() instanceof TestScope) and
  not (strOriginNode.getScope().getScope*() instanceof TestScope)
select currentLoop,
  "Iteration over $@, of class " + seqTypeValue.getClass().getName() + 
  ", may also iterate over $@.",
  seqOriginNode, "sequence", strOriginNode, "string"