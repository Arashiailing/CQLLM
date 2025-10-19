/**
 * @name Membership test with a non-container
 * @description Detects membership tests (e.g., 'item in sequence') where the right-hand side 
 *              is a non-container object, which would raise a 'TypeError' at runtime.
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
  ControlFlowNode valueOrigin
where
  // Identify right operand in membership test (In/NotIn operations)
  exists(Cmpop op, int idx |
    comparisonExpr.getOp(idx) = op and 
    comparisonExpr.getComparator(idx) = rightOperandNode.getNode() and
    (op instanceof In or op instanceof NotIn)
  ) and
  
  // Resolve value and class through points-to analysis
  rightOperandNode.pointsTo(_, targetValue, valueOrigin) and
  targetValue.getClass() = valueClass and
  
  // Exclude cases with failed type inference
  not Types::failedInference(valueClass, _) and
  
  // Verify absence of container-related capabilities
  not valueClass.hasAttribute("__contains__") and
  not valueClass.hasAttribute("__iter__") and
  not valueClass.hasAttribute("__getitem__") and
  
  // Exclude special container-like types
  not valueClass = ClassValue::nonetype() and
  not valueClass = Value::named("types.MappingProxyType")
select 
  comparisonExpr, 
  "This test may raise an Exception as the $@ may be of non-container class $@.", 
  valueOrigin, "target", valueClass, valueClass.getName()