/**
 * @name Non-iterable used in for loop
 * @description Detects for loops attempting to iterate over non-iterable objects, which would cause runtime TypeErrors.
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

// Identify for-loops using non-iterable values
from For forLoop, ControlFlowNode iterNode, Value iteratedValue, ClassValue iteratedType, ControlFlowNode sourceNode
where
  // Connect for-loop to its iterator expression node
  forLoop.getIter().getAFlowNode() = iterNode and
  // Trace iterator node to its source value and origin
  iterNode.pointsTo(_, iteratedValue, sourceNode) and
  // Obtain class type of the iterated value
  iteratedValue.getClass() = iteratedType and
  // Verify class type is non-iterable
  not iteratedType.isIterable() and
  // Exclude cases with failed type inference
  not iteratedType.failedInference(_) and
  // Exclude None values (intentionally non-iterable)
  not iteratedValue = Value::named("None") and
  // Exclude descriptor types with special iteration behavior
  not iteratedType.isDescriptorType()
select forLoop, "This for-loop may attempt to iterate over a $@ of class $@.", sourceNode,
  "non-iterable instance", iteratedType, iteratedType.getName()