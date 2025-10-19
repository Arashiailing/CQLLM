/**
 * @name Non-iterable used in for loop
 * @description Detects for-loops attempting to iterate over non-iterable objects, 
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

// Identify for-loops with non-iterable iteration targets
from For forLoop, ControlFlowNode iterNode, Value iteratedObj, ClassValue objClass, ControlFlowNode originNode
where
  // Connect for-loop to its iterator control flow node
  forLoop.getIter().getAFlowNode() = iterNode and
  // Extract the value being iterated and its source
  iterNode.pointsTo(_, iteratedObj, originNode) and
  // Determine the class of the iterated value
  iteratedObj.getClass() = objClass and
  // Verify the class lacks iteration capability
  not objClass.isIterable() and
  // Filter out false positive cases
  not objClass.failedInference(_) and    // Ensure valid type inference
  not iteratedObj = Value::named("None") and  // Exclude None values
  not objClass.isDescriptorType()        // Exclude descriptor types
select forLoop, "This for-loop may attempt to iterate over a $@ of class $@.", originNode,
  "non-iterable instance", objClass, objClass.getName()