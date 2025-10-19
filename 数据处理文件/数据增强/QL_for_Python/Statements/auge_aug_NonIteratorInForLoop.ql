/**
 * @name Non-iterable used in for loop
 * @description Identifies for loops that try to iterate over non-iterable objects, leading to runtime TypeError exceptions.
 * @kind problem
 * @tags reliability
 *       correctness
 *       types
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/non-iterable-in-for-loop
 */

import python

// Detects non-iterable objects used in for-loop iterations
from For loopStmt, ControlFlowNode iterNode, Value iteratedValue, ClassValue iteratedType, ControlFlowNode sourceNode
where
  // Establish connection between for-loop and its iterator node
  loopStmt.getIter().getAFlowNode() = iterNode and
  // Trace back iterator node to its source value and origin node
  iterNode.pointsTo(_, iteratedValue, sourceNode) and
  // Obtain and verify the class type of the value being iterated
  iteratedValue.getClass() = iteratedType and
  not iteratedType.isIterable() and
  // Exclude specific cases to reduce false positives
  not iteratedType.failedInference(_) and
  not iteratedValue = Value::named("None") and
  not iteratedType.isDescriptorType()
select loopStmt, "This for-loop may attempt to iterate over a $@ of class $@.", sourceNode,
  "non-iterable instance", iteratedType, iteratedType.getName()