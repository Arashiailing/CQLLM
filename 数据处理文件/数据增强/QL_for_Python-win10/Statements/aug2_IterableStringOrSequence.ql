/**
 * @name Iterable can be either a string or a sequence
 * @description Iteration over either a string or a sequence in the same loop can cause errors that are hard to find.
 * @kind problem
 * @tags reliability
 *       maintainability
 *       non-local
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/iteration-string-and-sequence
 */

import python  // Import Python library for code analysis
import semmle.python.filters.Tests  // Import test filter to exclude test code from analysis

// Predicate to determine if a value is of string type
// Returns true if the value is either a string (str) or unicode (in Python 2)
predicate isStringType(Value val) {
  val.getClass() = ClassValue::str()  // Check if the value's class is str
  or
  val.getClass() = ClassValue::unicode() and major_version() = 2  // Check for unicode in Python 2
}

from
  For targetLoop, ControlFlowNode iteratorNode, Value stringValue, Value sequenceValue,
  ControlFlowNode sequenceSourceNode, ControlFlowNode stringSourceNode  // Define variables for analysis
where
  // Establish relationship between loop and its iterator
  targetLoop.getIter().getAFlowNode() = iteratorNode and
  
  // Connect iterator to both string and sequence values with their origins
  iteratorNode.pointsTo(stringValue, stringSourceNode) and
  iteratorNode.pointsTo(sequenceValue, sequenceSourceNode) and
  
  // Verify that one value is a string and the other is a non-string iterable
  isStringType(stringValue) and
  sequenceValue.getClass().isIterable() and
  not isStringType(sequenceValue) and
  
  // Exclude test code from the analysis results
  not (sequenceSourceNode.getScope().getScope*() instanceof TestScope) and
  not (stringSourceNode.getScope().getScope*() instanceof TestScope)
select targetLoop,
  "Iteration over $@, of class " + sequenceValue.getClass().getName() + ", may also iterate over $@.",
  sequenceSourceNode, "sequence", stringSourceNode, "string"  // Report the issue with appropriate message