/**
 * @name Non-iterable used in for loop
 * @description Identifies for loops attempting to iterate over non-iterable objects, which would cause runtime TypeErrors.
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

// Identify for loops with non-iterable operands
from For forLoop, ControlFlowNode iterationExprNode, Value iteratedObject, ClassValue objectClass, ControlFlowNode valueSourceLocation
where
  // Link for loop to its iteration expression and trace to the actual value being iterated
  forLoop.getIter().getAFlowNode() = iterationExprNode and
  iterationExprNode.pointsTo(_, iteratedObject, valueSourceLocation) and
  
  // Obtain the class of the iterated object and verify it's a valid non-iterable type
  iteratedObject.getClass() = objectClass and
  not objectClass.isIterable() and
  not objectClass.failedInference(_) and
  
  // Exclude false positives: None values and descriptor types with special handling
  not (iteratedObject = Value::named("None") or objectClass.isDescriptorType())
select forLoop, "This for-loop may attempt to iterate over a $@ of class $@.", valueSourceLocation,
  "non-iterable instance", objectClass, objectClass.getName()