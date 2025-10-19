/**
 * @name Non-iterable used in for loop
 * @description Identifies for-loops that iterate over non-iterable objects, which would raise a TypeError at runtime.
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

// Detects for-loops using non-iterable objects
from For loopStmt, ControlFlowNode iteratorNode, Value iteratedValue, ClassValue iteratedClass, ControlFlowNode sourceNode
where
  // Link for-statement to its iterator control flow node
  loopStmt.getIter().getAFlowNode() = iteratorNode and
  // Track value pointed by iterator node and its origin
  iteratorNode.pointsTo(_, iteratedValue, sourceNode) and
  // Obtain class type of the iterated value
  iteratedValue.getClass() = iteratedClass and
  // Verify class is non-iterable
  not iteratedClass.isIterable() and
  // Exclude problematic false positive cases
  not iteratedClass.failedInference(_) and  // Valid type inference
  not iteratedValue = Value::named("None") and  // Non-None value
  not iteratedClass.isDescriptorType()  // Non-descriptor type
select loopStmt, "This for-loop may attempt to iterate over a $@ of class $@.", sourceNode,
  "non-iterable instance", iteratedClass, iteratedClass.getName()