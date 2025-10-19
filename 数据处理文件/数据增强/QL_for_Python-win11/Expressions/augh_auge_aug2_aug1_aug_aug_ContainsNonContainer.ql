/**
 * @name Membership test with non-container type
 * @description Detects membership tests ('in'/'not in') where the right-hand side is not a container type,
 *              which can lead to runtime TypeErrors.
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
  ControlFlowNode rhsNode, 
  Compare cmpExpr, 
  Value inferredValue, 
  ClassValue nonContainerCls, 
  ControlFlowNode originNode
where
  // Identify membership test right operand
  exists(Cmpop op, int idx |
    cmpExpr.getOp(idx) = op and 
    cmpExpr.getComparator(idx) = rhsNode.getNode() and
    (op instanceof In or op instanceof NotIn)
  ) and
  
  // Resolve type information through points-to analysis
  rhsNode.pointsTo(_, inferredValue, originNode) and
  inferredValue.getClass() = nonContainerCls and
  
  // Exclude cases with incomplete type inference
  not Types::failedInference(nonContainerCls, _) and
  
  // Verify absence of container interface methods
  (not nonContainerCls.hasAttribute("__contains__") and
   not nonContainerCls.hasAttribute("__iter__") and
   not nonContainerCls.hasAttribute("__getitem__")) and
  
  // Filter out pseudo-container types
  (not nonContainerCls = ClassValue::nonetype() and
   not nonContainerCls = Value::named("types.MappingProxyType"))
select 
  cmpExpr, 
  "This membership test may raise an Exception because $@ might be of non-container class $@.", 
  originNode, "target", nonContainerCls, nonContainerCls.getName()