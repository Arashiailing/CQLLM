/**
 * @name Iterable can be either a string or a sequence
 * @description Identifies code patterns where a loop iterates over both strings and sequences,
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

// Helper predicate to identify string values
// Returns true for str type and unicode type (in Python 2)
predicate isStringType(Value val) {
  val.getClass() = ClassValue::str()  // Standard string type
  or
  val.getClass() = ClassValue::unicode() and major_version() = 2  // Unicode type in Python 2
}

from 
  For problematicLoop, ControlFlowNode iterableNode, Value strVal, Value seqVal,
  ControlFlowNode seqOriginNode, ControlFlowNode strOriginNode
where
  // Establish loop-iterator relationship
  problematicLoop.getIter().getAFlowNode() = iterableNode and
  
  // Connect iterator to both string and sequence values with their source nodes
  iterableNode.pointsTo(strVal, strOriginNode) and
  iterableNode.pointsTo(seqVal, seqOriginNode) and
  
  // Verify type conditions: one is string, other is non-string iterable
  isStringType(strVal) and
  seqVal.getClass().isIterable() and
  not isStringType(seqVal) and
  
  // Filter out test code to reduce false positives
  not (seqOriginNode.getScope().getScope*() instanceof TestScope) and
  not (strOriginNode.getScope().getScope*() instanceof TestScope)
select problematicLoop,
  "Iteration over $@, of class " + seqVal.getClass().getName() + ", may also iterate over $@.",
  seqOriginNode, "sequence", strOriginNode, "string"