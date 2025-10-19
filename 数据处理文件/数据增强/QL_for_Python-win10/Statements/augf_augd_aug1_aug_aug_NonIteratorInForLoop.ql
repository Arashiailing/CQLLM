/**
 * @name Non-iterable used in for loop
 * @description Identifies for-loops that iterate over non-iterable objects, which would raise a TypeError at runtime.
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

// Locates for-loops attempting to iterate over non-iterable objects
from For stmt, ControlFlowNode iteratorExpr, Value iteratedObj, ClassValue objClass, ControlFlowNode objSource
where
  // Link the for-loop with its iterator expression in control flow
  stmt.getIter().getAFlowNode() = iteratorExpr and
  // Trace the value being iterated and its origin point
  iteratorExpr.pointsTo(_, iteratedObj, objSource) and
  // Determine the class of the iterated value
  iteratedObj.getClass() = objClass and
  // Confirm the class lacks iteration capability
  not objClass.isIterable() and
  // Exclude false positive scenarios:
  // 1. Type inference succeeded for this class
  not objClass.failedInference(_) and
  // 2. Value is not the None singleton
  not iteratedObj = Value::named("None") and
  // 3. Value is not a descriptor type
  not objClass.isDescriptorType()
select stmt, "This for-loop may attempt to iterate over a $@ of class $@.", objSource,
  "non-iterable instance", objClass, objClass.getName()