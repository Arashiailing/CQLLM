/**
 * @name Membership test with non-container operand
 * @description Identifies membership tests (e.g., 'item in sequence') where the right-hand 
 *              operand is a non-container object, which would raise a 'TypeError' at runtime.
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
 * Identifies right-hand operands in membership comparison operations.
 * @param rhsNode - Control flow node evaluated as right operand
 * @param cmpExpr - Comparison expression containing the membership test
 */
predicate isRhsInMembershipTest(ControlFlowNode rhsNode, Compare cmpExpr) {
  exists(Cmpop operation, int idx |
    cmpExpr.getOp(idx) = operation and 
    cmpExpr.getComparator(idx) = rhsNode.getNode() and
    (operation instanceof In or operation instanceof NotIn)
  )
}

from 
  ControlFlowNode rhsNode, 
  Compare cmpExpr, 
  Value pointedValue, 
  ClassValue rhsClass, 
  ControlFlowNode sourceNode
where
  // Identify membership tests and extract right operand
  isRhsInMembershipTest(rhsNode, cmpExpr) and
  
  // Resolve operand value and its class
  rhsNode.pointsTo(_, pointedValue, sourceNode) and
  pointedValue.getClass() = rhsClass and
  
  // Validate type inference success
  not Types::failedInference(rhsClass, _) and
  
  // Verify non-container characteristics
  (not rhsClass.hasAttribute("__contains__") and
   not rhsClass.hasAttribute("__iter__") and
   not rhsClass.hasAttribute("__getitem__")) and
  not rhsClass = ClassValue::nonetype() and
  not rhsClass = Value::named("types.MappingProxyType")
select 
  cmpExpr, 
  "This test may raise an Exception as the $@ may be of non-container class $@.", 
  sourceNode, "target", rhsClass, rhsClass.getName()