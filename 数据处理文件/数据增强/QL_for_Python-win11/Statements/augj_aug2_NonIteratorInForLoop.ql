/**
 * @name Non-iterable used in for loop
 * @description Identifies for-loops attempting to iterate over non-iterable objects,
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

// Detect for-loops with non-iterable iteration targets
from For loop, 
     ControlFlowNode iterNode, 
     Value iterValue, 
     ClassValue valueClass, 
     ControlFlowNode originNode
where
  // Extract iterator node from the loop's iteration target
  loop.getIter().getAFlowNode() = iterNode and
  
  // Trace value and its source through data flow analysis
  iterNode.pointsTo(_, iterValue, originNode) and
  
  // Determine the class type of the traced value
  iterValue.getClass() = valueClass and
  
  // Verify the class type is not iterable
  not valueClass.isIterable() and
  
  // Exclude cases with failed type inference
  not valueClass.failedInference(_) and
  
  // Exclude None values (handled separately by type system)
  iterValue != Value::named("None") and
  
  // Exclude descriptor types (special protocol objects)
  not valueClass.isDescriptorType()
select loop, 
       "This for-loop may attempt to iterate over a $@ of class $@.", 
       originNode, "non-iterable instance", 
       valueClass, valueClass.getName()