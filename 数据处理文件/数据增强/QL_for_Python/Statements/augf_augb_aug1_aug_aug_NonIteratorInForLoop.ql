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

// Identify for-loops that attempt to iterate over non-iterable objects
from For loopStmt, 
     ControlFlowNode iteratorNode, 
     Value iteratedValue, 
     ClassValue iteratedClass, 
     ControlFlowNode sourceNode
where
  // Connect the for-loop statement to its iterator expression in the control flow graph
  loopStmt.getIter().getAFlowNode() = iteratorNode and
  
  // Trace the value being iterated and its origin in the code
  iteratorNode.pointsTo(_, iteratedValue, sourceNode) and
  
  // Determine the class of the iterated value
  iteratedValue.getClass() = iteratedClass and
  
  // Check if the class is not iterable (would cause TypeError at runtime)
  not iteratedClass.isIterable() and
  
  // Exclude false positives by filtering out specific cases
  // Ensure the type inference is valid
  not iteratedClass.failedInference(_) and
  // Exclude None values which are commonly used but not iterable
  not iteratedValue = Value::named("None") and
  // Exclude descriptor types which have special behavior
  not iteratedClass.isDescriptorType()
select loopStmt, 
       "This for-loop may attempt to iterate over a $@ of class $@.", 
       sourceNode, 
       "non-iterable instance", 
       iteratedClass, 
       iteratedClass.getName()