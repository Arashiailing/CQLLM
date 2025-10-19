/**
 * @name Non-iterable used in for loop
 * @description Detects for loops that attempt to iterate over non-iterable objects, which would cause a TypeError at runtime.
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

// Identify for loops attempting to iterate over non-iterable objects
from For forLoop, ControlFlowNode iterableNode, Value iteratedValue, ClassValue valueClass, ControlFlowNode sourceLocation
where
  // Establish relationship between for loop and its iteration expression
  forLoop.getIter().getAFlowNode() = iterableNode and
  // Trace the value being iterated and its origin point
  iterableNode.pointsTo(_, iteratedValue, sourceLocation) and
  
  // Determine the class of the iterated value and verify it's not iterable
  iteratedValue.getClass() = valueClass and
  not valueClass.isIterable() and
  // Exclude cases where type inference failed
  not valueClass.failedInference(_) and
  
  // Filter out special cases to prevent false positives
  not (iteratedValue = Value::named("None") or valueClass.isDescriptorType())
select forLoop, "This for-loop may attempt to iterate over a $@ of class $@.", sourceLocation,
  "non-iterable instance", valueClass, valueClass.getName()