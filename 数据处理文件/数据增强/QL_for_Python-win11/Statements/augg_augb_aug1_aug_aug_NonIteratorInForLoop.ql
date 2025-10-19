/**
 * @name Non-iterable used in for loop
 * @description Identifies for-loops that attempt to iterate over non-iterable objects,
 *              which would result in runtime TypeErrors during execution.
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

// Identify for-loops that iterate over non-iterable objects
from For loopStmt, 
     ControlFlowNode iterationNode, 
     Value iteratedObject, 
     ClassValue objectClass, 
     ControlFlowNode sourceNode
where
  // Connect the for-loop with its iteration expression
  loopStmt.getIter().getAFlowNode() = iterationNode and
  
  // Track the value being iterated and its origin
  iterationNode.pointsTo(_, iteratedObject, sourceNode) and
  
  // Determine the class of the iterated value
  iteratedObject.getClass() = objectClass and
  
  // Ensure the class is not iterable
  not objectClass.isIterable() and
  
  // Exclude false positives
  not objectClass.failedInference(_) and  // Valid type inference
  not iteratedObject = Value::named("None") and  // Not None values
  not objectClass.isDescriptorType()  // Not descriptor types
select loopStmt, 
       "This for-loop may attempt to iterate over a $@ of class $@.", 
       sourceNode, 
       "non-iterable instance", 
       objectClass, 
       objectClass.getName()