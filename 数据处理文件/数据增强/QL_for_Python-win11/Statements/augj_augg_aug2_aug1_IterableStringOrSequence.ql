/**
 * @name Iterable can be either a string or a sequence
 * @description Identifies loops that iterate over both string and sequence types,
 * which may lead to runtime errors due to inconsistent iteration behavior
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

// Predicate to determine if a value represents string types (str or Python 2 unicode)
predicate is_string_type(Value val) {
  val.getClass() = ClassValue::str() 
  or 
  val.getClass() = ClassValue::unicode() and major_version() = 2
}

from 
  For loopNode, 
  ControlFlowNode iterableNode, 
  Value strVal, 
  Value seqVal, 
  ControlFlowNode seqOrigin,
  ControlFlowNode strOrigin
where 
  // Link loop to its iterable expression's control flow node
  loopNode.getIter().getAFlowNode() = iterableNode and
  
  // Track data flow paths to both string and sequence values
  iterableNode.pointsTo(strVal, strOrigin) and
  iterableNode.pointsTo(seqVal, seqOrigin) and
  
  // Verify type characteristics: string and non-string iterable
  is_string_type(strVal) and
  seqVal.getClass().isIterable() and
  not is_string_type(seqVal) and
  
  // Exclude test-related code paths from analysis
  not seqOrigin.getScope().getScope*() instanceof TestScope and
  not strOrigin.getScope().getScope*() instanceof TestScope
select loopNode,
  "Iteration over $@, of class " + seqVal.getClass().getName() + 
  ", may also iterate over $@.",
  seqOrigin, "sequence", strOrigin, "string"