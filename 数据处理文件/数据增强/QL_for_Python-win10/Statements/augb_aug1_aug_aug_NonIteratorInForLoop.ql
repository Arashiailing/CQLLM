/**
 * @name Non-iterable used in for loop
 * @description Detects for-loops attempting to iterate over non-iterable objects, which would cause runtime TypeErrors.
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

// Identify problematic for-loops with non-iterable iteration targets
from For forLoop, 
     ControlFlowNode iterNode, 
     Value targetValue, 
     ClassValue targetClass, 
     ControlFlowNode originNode
where
  // Establish connection between for-loop and its iterator node
  forLoop.getIter().getAFlowNode() = iterNode and
  
  // Trace the iterated value and its origin source
  iterNode.pointsTo(_, targetValue, originNode) and
  
  // Determine class type of the iterated value
  targetValue.getClass() = targetClass and
  
  // Verify the class lacks iteration capability
  not targetClass.isIterable() and
  
  // Filter out false positive cases
  not targetClass.failedInference(_) and  // Ensure valid type inference
  not targetValue = Value::named("None") and  // Exclude None values
  not targetClass.isDescriptorType()  // Exclude descriptor types
select forLoop, 
       "This for-loop may attempt to iterate over a $@ of class $@.", 
       originNode, 
       "non-iterable instance", 
       targetClass, 
       targetClass.getName()