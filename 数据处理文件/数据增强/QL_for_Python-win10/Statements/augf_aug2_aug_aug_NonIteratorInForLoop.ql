/**
 * @name Non-iterable used in for loop
 * @description Detects for-loops that attempt to iterate over non-iterable objects, 
 *              which would cause a TypeError at runtime.
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

// Identify for-loops attempting to iterate over non-iterable objects
from For forLoop, ControlFlowNode iterNode, Value targetValue, ClassValue targetClass, ControlFlowNode originNode
where
  // Establish relationship between for-loop and its iterator node
  forLoop.getIter().getAFlowNode() = iterNode and
  // Trace the value referenced by iterator node and its origin through data flow analysis
  iterNode.pointsTo(_, targetValue, originNode) and
  // Obtain the class type of the iterated value
  targetValue.getClass() = targetClass and
  // Verify the class lacks iterable capability
  not targetClass.isIterable() and
  // Filter out false positives by excluding special cases
  not targetClass.failedInference(_) and  // Ensure successful type inference
  not targetValue = Value::named("None") and  // Exclude None values
  not targetClass.isDescriptorType()  // Exclude descriptor types
select forLoop, "This for-loop may attempt to iterate over a $@ of class $@.", originNode,
  "non-iterable instance", targetClass, targetClass.getName()