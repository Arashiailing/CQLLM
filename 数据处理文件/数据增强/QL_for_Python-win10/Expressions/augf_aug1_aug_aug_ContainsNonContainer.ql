/**
 * @name Membership test with a non-container
 * @description Detects membership operations ('in'/'not in') where the right-hand operand 
 *              is a non-container type, leading to runtime TypeError.
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

/**
 * Identifies nodes serving as right operands in membership tests.
 * @param node - Control flow node being analyzed
 * @param cmpNode - Comparison expression containing the membership test
 */
predicate isRightHandSideOfInTest(ControlFlowNode node, Compare cmpNode) {
  exists(Cmpop op, int idx |
    cmpNode.getOp(idx) = op and 
    cmpNode.getComparator(idx) = node.getNode() and
    (op instanceof In or op instanceof NotIn)
  )
}

from 
  ControlFlowNode rhsNode, 
  Compare cmpExpr, 
  Value pointedVal, 
  ClassValue nonContainerCls, 
  ControlFlowNode origin
where
  // Verify membership test context
  isRightHandSideOfInTest(rhsNode, cmpExpr) and
  
  // Resolve type information
  rhsNode.pointsTo(_, pointedVal, origin) and
  pointedVal.getClass() = nonContainerCls and
  
  // Exclude inference failures
  not Types::failedInference(nonContainerCls, _) and
  
  // Confirm non-container characteristics
  (not nonContainerCls.hasAttribute("__contains__") and
   not nonContainerCls.hasAttribute("__iter__") and
   not nonContainerCls.hasAttribute("__getitem__")) and
  
  // Exclude pseudo-container types
  (nonContainerCls != ClassValue::nonetype() and
   nonContainerCls != Value::named("types.MappingProxyType"))
select 
  cmpExpr, 
  "This test may raise an Exception as the $@ might be of non-container class $@.", 
  origin, "target", nonContainerCls, nonContainerCls.getName()