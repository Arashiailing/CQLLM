/**
 * @name Non-iterable used in for loop
 * @description Detects for-loops attempting to iterate over non-iterable objects,
 *              which will cause a TypeError at runtime.
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
from For forLoop, ControlFlowNode iteratorNode, Value value, ClassValue typeClass, ControlFlowNode sourceNode
where
  // Extract iterator node from the for-loop's iteration target
  forLoop.getIter().getAFlowNode() = iteratorNode and
  // Trace value and its source from the iterator node
  iteratorNode.pointsTo(_, value, sourceNode) and
  // Determine the class type of the traced value
  value.getClass() = typeClass and
  // Verify the class type is not iterable
  not typeClass.isIterable() and
  // Exclude cases with failed type inference
  not typeClass.failedInference(_) and
  // Exclude None values (handled separately by type system)
  value != Value::named("None") and
  // Exclude descriptor types (special protocol objects)
  not typeClass.isDescriptorType()
select forLoop, "This for-loop may attempt to iterate over a $@ of class $@.", sourceNode,
  "non-iterable instance", typeClass, typeClass.getName()