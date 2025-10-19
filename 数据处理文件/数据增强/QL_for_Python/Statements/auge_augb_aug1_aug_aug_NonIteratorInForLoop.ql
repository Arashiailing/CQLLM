/**
 * @name Non-iterable used in for loop
 * @description Identifies for-loops iterating over non-iterable objects that would cause TypeErrors at runtime.
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

// Locate for-loops with potentially non-iterable iteration targets
from For loopStatement, 
     ControlFlowNode iteratorNode, 
     Value iteratedValue, 
     ClassValue iteratedClass, 
     ControlFlowNode sourceNode
where
  // Link for-loop to its iterator node in control flow
  loopStatement.getIter().getAFlowNode() = iteratorNode and
  
  // Trace the value being iterated and its origin
  iteratorNode.pointsTo(_, iteratedValue, sourceNode) and
  
  // Determine the class type of the iterated value
  iteratedValue.getClass() = iteratedClass and
  
  // Confirm the class lacks iteration capability
  not iteratedClass.isIterable() and
  
  // Exclude false positives through filtering conditions
  not iteratedClass.failedInference(_) and  // Valid type inference required
  not iteratedValue = Value::named("None") and  // None values excluded
  not iteratedClass.isDescriptorType()  // Descriptor types excluded
select loopStatement, 
       "This for-loop attempts to iterate over a $@ of type $@.", 
       sourceNode, 
       "non-iterable value", 
       iteratedClass, 
       iteratedClass.getName()