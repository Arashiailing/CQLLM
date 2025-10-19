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
from For forLoop, ControlFlowNode iterNode, Value targetValue, ClassValue targetClass, ControlFlowNode valueOrigin
where
  // Establish relationship between for-loop and its iterator node
  forLoop.getIter().getAFlowNode() = iterNode and
  // Track the value being iterated and its origin
  iterNode.pointsTo(_, targetValue, valueOrigin) and
  // Determine the class of the iterated value
  targetValue.getClass() = targetClass and
  // Verify the class is non-iterable
  not targetClass.isIterable() and
  // Exclude false positive cases:
  // 1. Valid type inference was performed
  not targetClass.failedInference(_) and
  // 2. Value is not None
  not targetValue = Value::named("None") and
  // 3. Value is not a descriptor type
  not targetClass.isDescriptorType()
select forLoop, "This for-loop may attempt to iterate over a $@ of class $@.", valueOrigin,
  "non-iterable instance", targetClass, targetClass.getName()