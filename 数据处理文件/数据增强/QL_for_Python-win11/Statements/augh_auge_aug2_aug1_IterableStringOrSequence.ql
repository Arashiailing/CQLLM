/**
 * @name Iterable can be either a string or a sequence
 * @description Detects loops that iterate over both string and sequence types,
 * which may cause runtime errors due to inconsistent iteration behavior.
 * This occurs when the same iterator node references both string and non-string
 * iterable values, potentially leading to unexpected runtime behavior.
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
predicate isStringType(Value value) {
  value.getClass() = ClassValue::str() 
  or 
  value.getClass() = ClassValue::unicode() and major_version() = 2
}

from 
  For forLoop, 
  ControlFlowNode iterNode, 
  Value strValue, 
  Value seqValue, 
  ControlFlowNode seqOrigin,
  ControlFlowNode strOrigin
where 
  // Establish connection between loop and its iterator
  forLoop.getIter().getAFlowNode() = iterNode
  
  // Verify iterator points to both string and sequence values
  and iterNode.pointsTo(strValue, strOrigin)
  and iterNode.pointsTo(seqValue, seqOrigin)
  
  // Validate string type for one value
  and isStringType(strValue)
  
  // Validate sequence type for the other value (non-string iterable)
  and seqValue.getClass().isIterable()
  and not isStringType(seqValue)
  
  // Exclude test code scenarios
  and not seqOrigin.getScope().getScope*() instanceof TestScope
  and not strOrigin.getScope().getScope*() instanceof TestScope
select forLoop,
  "Iteration over $@, of class " + seqValue.getClass().getName() + 
  ", may also iterate over $@.",
  seqOrigin, "sequence", strOrigin, "string"