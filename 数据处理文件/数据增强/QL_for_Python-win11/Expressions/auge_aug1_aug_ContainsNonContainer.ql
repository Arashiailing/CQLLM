/**
 * @name Membership test with a non-container
 * @description Identifies membership tests (e.g., 'item in sequence') where the right-hand side 
 *              operand is a non-container object, which would result in a 'TypeError' at runtime.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/member-test-non-container
 */

import python
import semmle.python.pointsto.PointsTo

from 
  ControlFlowNode rightOperandNode, 
  Compare comparisonExpr, 
  Value targetValue, 
  ClassValue valueClass, 
  ControlFlowNode sourceNode
where
  // Identify right operand in membership test operations
  exists(Cmpop op, int idx |
    comparisonExpr.getOp(idx) = op and 
    comparisonExpr.getComparator(idx) = rightOperandNode.getNode() and
    (op instanceof In or op instanceof NotIn)
  ) and
  
  // Resolve the value and class of the right operand
  rightOperandNode.pointsTo(_, targetValue, sourceNode) and
  targetValue.getClass() = valueClass and
  
  // Exclude cases where type inference failed
  not Types::failedInference(valueClass, _) and
  
  // Verify the class lacks container capabilities
  not valueClass.hasAttribute("__contains__") and
  not valueClass.hasAttribute("__iter__") and
  not valueClass.hasAttribute("__getitem__") and
  
  // Exclude special container-like types
  not valueClass = ClassValue::nonetype() and
  not valueClass = Value::named("types.MappingProxyType")
select 
  comparisonExpr, 
  "This membership test may raise an Exception as the $@ might be of non-container class $@.", 
  sourceNode, "target", valueClass, valueClass.getName()