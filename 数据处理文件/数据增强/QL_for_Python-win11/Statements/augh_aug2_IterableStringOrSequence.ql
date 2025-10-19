/**
 * @name Iterable can be either a string or a sequence
 * @description Detects loops that iterate over values which can be either strings or sequences,
 *              potentially causing hard-to-diagnose runtime errors.
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

// Predicate that identifies if a value represents a string type
// Returns true for string (str) or unicode (Python 2) values
predicate isStringType(Value val) {
  val.getClass() = ClassValue::str()  // Check if the value's class is str
  or
  val.getClass() = ClassValue::unicode() and major_version() = 2  // Check for unicode in Python 2
}

from
  For targetLoop, ControlFlowNode iteratorNode, Value stringVal, Value sequenceVal,
  ControlFlowNode sequenceSrcNode, ControlFlowNode stringSrcNode  // Define variables for analysis
where
  // Establish relationship between loop and its iterator
  targetLoop.getIter().getAFlowNode() = iteratorNode and
  
  // Connect iterator to both string and sequence values with their origins
  iteratorNode.pointsTo(stringVal, stringSrcNode) and
  iteratorNode.pointsTo(sequenceVal, sequenceSrcNode) and
  
  // Verify that one value is a string and the other is a non-string iterable
  isStringType(stringVal) and
  sequenceVal.getClass().isIterable() and
  not isStringType(sequenceVal) and
  
  // Exclude test code from the analysis results
  not (sequenceSrcNode.getScope().getScope*() instanceof TestScope) and
  not (stringSrcNode.getScope().getScope*() instanceof TestScope)
select targetLoop,
  "Iteration over $@, of class " + sequenceVal.getClass().getName() + ", may also iterate over $@.",
  sequenceSrcNode, "sequence", stringSrcNode, "string"  // Report the issue with appropriate message