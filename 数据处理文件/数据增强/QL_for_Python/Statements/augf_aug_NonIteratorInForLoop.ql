/**
 * @name Non-iterable used in for loop
 * @description Detects for loops attempting to iterate over non-iterable objects, which would cause a TypeError at runtime.
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

// Identify for loops using non-iterable values for iteration
from For loopStmt, ControlFlowNode iterNode, Value iteratedValue, ClassValue iteratedClass, ControlFlowNode sourceNode
where
  // Establish connection between for-loop and its iterator node
  loopStmt.getIter().getAFlowNode() = iterNode and
  // Trace iterator node to its source value and origin node
  iterNode.pointsTo(_, iteratedValue, sourceNode) and
  // Obtain the class type of the iterated value
  iteratedValue.getClass() = iteratedClass and
  // Verify the class type is non-iterable
  not iteratedClass.isIterable() and
  // Exclude cases where type inference failed
  not iteratedClass.failedInference(_) and
  // Exclude None values (non-iterable but typically intentional)
  not iteratedValue = Value::named("None") and
  // Exclude descriptor types (may have special iteration behavior)
  not iteratedClass.isDescriptorType()
select loopStmt, "This for-loop may attempt to iterate over a $@ of class $@.", sourceNode,
  "non-iterable instance", iteratedClass, iteratedClass.getName()