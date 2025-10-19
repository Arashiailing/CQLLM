/**
 * @name Membership test with a non-container
 * @description Detects membership operations ('in'/'not in') where the right-hand operand 
 *              is a non-container type, which may cause runtime TypeError.
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
  Value pointedValue, 
  ClassValue nonContainerType, 
  ControlFlowNode originNode
where
  // Identify membership test right operand
  exists(Cmpop operation, int operandIndex |
    comparisonExpr.getOp(operandIndex) = operation and 
    comparisonExpr.getComparator(operandIndex) = rightOperandNode.getNode() and
    (operation instanceof In or operation instanceof NotIn)
  ) and
  
  // Resolve type information
  rightOperandNode.pointsTo(_, pointedValue, originNode) and
  pointedValue.getClass() = nonContainerType and
  
  // Exclude type inference failures
  not Types::failedInference(nonContainerType, _) and
  
  // Verify non-container characteristics
  not nonContainerType.hasAttribute("__contains__") and
  not nonContainerType.hasAttribute("__iter__") and
  not nonContainerType.hasAttribute("__getitem__") and
  
  // Exclude pseudo-container exceptions
  not nonContainerType = ClassValue::nonetype() and
  not nonContainerType = Value::named("types.MappingProxyType")
select 
  comparisonExpr, 
  "This test may raise an Exception as the $@ may be of non-container class $@.", 
  originNode, "target", nonContainerType, nonContainerType.getName()