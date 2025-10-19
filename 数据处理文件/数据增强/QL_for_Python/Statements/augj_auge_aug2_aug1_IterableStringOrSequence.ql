/**
 * @name Iterable can be either a string or a sequence
 * @description Identifies loops that iterate over both string and sequence types,
 * which may lead to runtime errors due to inconsistent iteration behavior.
 * This occurs when the same iterator node can reference both string and non-string
 * iterable values, potentially causing unexpected runtime behavior.
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
predicate is_string_type(Value val) {
  val.getClass() = ClassValue::str() 
  or 
  val.getClass() = ClassValue::unicode() and major_version() = 2
}

from 
  For loopNode, 
  ControlFlowNode iterNode, 
  Value strValue, 
  Value seqValue, 
  ControlFlowNode seqOrigin,
  ControlFlowNode strOrigin
where 
  // Establish connection between loop and its iterator
  loopNode.getIter().getAFlowNode() = iterNode
  
  // Verify iterator points to both string and sequence values
  and iterNode.pointsTo(strValue, strOrigin)
  and iterNode.pointsTo(seqValue, seqOrigin)
  
  // Validate string type for one value
  and is_string_type(strValue)
  
  // Validate sequence type for the other value (non-string iterable)
  and seqValue.getClass().isIterable()
  and not is_string_type(seqValue)
  
  // Exclude test code scenarios
  and not seqOrigin.getScope().getScope*() instanceof TestScope
  and not strOrigin.getScope().getScope*() instanceof TestScope
select loopNode,
  "Iteration over $@, of class " + seqValue.getClass().getName() + 
  ", may also iterate over $@.",
  seqOrigin, "sequence", strOrigin, "string"