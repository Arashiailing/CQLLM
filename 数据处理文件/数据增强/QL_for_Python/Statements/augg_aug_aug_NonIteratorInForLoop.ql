/**
 * @name Non-iterable used in for loop
 * @description Identifies for-loops that iterate over non-iterable objects, which would raise a TypeError at runtime.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/non-iterable-in-for-loop
 */

import python

// Detects for-loops attempting to iterate over non-iterable objects
// Such operations would cause runtime TypeErrors when iteration is attempted
from For loopStatement, ControlFlowNode iteratorNode, Value iteratedValue, ClassValue valueClass, ControlFlowNode sourceNode
where
  // Establish connection between for-loop and its iterator flow node
  loopStatement.getIter().getAFlowNode() = iteratorNode and
  // Trace back from iterator node to the actual value and its origin
  iteratorNode.pointsTo(_, iteratedValue, sourceNode) and
  // Determine the class type of the value being iterated
  iteratedValue.getClass() = valueClass and
  // Confirm that the class type lacks iterable capability
  not valueClass.isIterable() and
  // Filter out special cases that could lead to false positives
  not valueClass.failedInference(_) and  // Exclude classes with failed type inference
  not iteratedValue = Value::named("None") and  // Exclude None literal values
  not valueClass.isDescriptorType()  // Exclude descriptor type classes
select loopStatement, "This for-loop may attempt to iterate over a $@ of class $@.", sourceNode,
  "non-iterable instance", valueClass, valueClass.getName()