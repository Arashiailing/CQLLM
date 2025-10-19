/**
 * @name Iterable can be either a string or a sequence
 * @description Detects loops that iterate over both string and sequence types, 
 * which can cause hard-to-diagnose runtime errors due to inconsistent iteration behavior
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

// Identifies string types (str or Python 2 unicode)
predicate is_string_type(Value value) {
  value.getClass() = ClassValue::str() 
  or 
  value.getClass() = ClassValue::unicode() and major_version() = 2
}

from 
  For loop, 
  ControlFlowNode iterNode, 
  Value strValue, 
  Value seqValue, 
  ControlFlowNode seqOrigin,
  ControlFlowNode strOrigin
where 
  // Connect loop iterator to both string and sequence values
  loop.getIter().getAFlowNode() = iterNode and
  iterNode.pointsTo(strValue, strOrigin) and
  iterNode.pointsTo(seqValue, seqOrigin) and
  
  // Type validation: string and non-string iterable
  is_string_type(strValue) and
  seqValue.getClass().isIterable() and
  not is_string_type(seqValue) and
  
  // Exclude test-related code paths
  not seqOrigin.getScope().getScope*() instanceof TestScope and
  not strOrigin.getScope().getScope*() instanceof TestScope
select loop,
  "Iteration over $@, of class " + seqValue.getClass().getName() + 
  ", may also iterate over $@.",
  seqOrigin, "sequence", strOrigin, "string"