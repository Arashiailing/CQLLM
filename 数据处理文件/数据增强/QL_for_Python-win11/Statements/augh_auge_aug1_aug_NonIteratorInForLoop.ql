/**
 * @name Non-iterable used in for loop
 * @description Detects for loops attempting to iterate over non-iterable objects, 
 *              which would cause runtime TypeErrors during execution.
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
from For loopTarget, ControlFlowNode iterExprNode, Value iteratedValue, ClassValue valueClass, ControlFlowNode originNode
where
  // Connect for loop to its iteration expression and trace to the actual value being iterated
  loopTarget.getIter().getAFlowNode() = iterExprNode and
  iterExprNode.pointsTo(_, iteratedValue, originNode) and
  
  // Obtain the class of the iterated object and verify it's a valid non-iterable type
  iteratedValue.getClass() = valueClass and
  not valueClass.isIterable() and
  not valueClass.failedInference(_) and
  
  // Exclude false positives: None values and descriptor types with special handling
  iteratedValue != Value::named("None") and
  not valueClass.isDescriptorType()
select loopTarget, "This for-loop may attempt to iterate over a $@ of class $@.", originNode,
  "non-iterable instance", valueClass, valueClass.getName()