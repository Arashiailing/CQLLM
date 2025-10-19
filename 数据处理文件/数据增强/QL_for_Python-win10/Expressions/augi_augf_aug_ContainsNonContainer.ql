/**
 * @name Membership test with a non-container
 * @description Identifies membership tests (e.g., 'item in sequence') where the right-hand side 
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

/**
 * Determines if a node serves as the right operand in In/NotIn operations.
 * @param node - The control flow node being evaluated
 * @param compareNode - The comparison expression containing the operation
 */
predicate isRightOperandOfMembershipTest(ControlFlowNode node, Compare compareNode) {
  exists(Cmpop operation, int operandIndex |
    compareNode.getOp(operandIndex) = operation and 
    compareNode.getComparator(operandIndex) = node.getNode() and
    (operation instanceof In or operation instanceof NotIn)
  )
}

from 
  ControlFlowNode rightOperandNode, 
  Compare comparisonExpr, 
  Value pointedToValue, 
  ClassValue objectClass, 
  ControlFlowNode sourceNode
where
  // Identify membership test operations with node as right operand
  isRightOperandOfMembershipTest(rightOperandNode, comparisonExpr) and
  
  // Resolve the node's pointed value and its class
  rightOperandNode.pointsTo(_, pointedToValue, sourceNode) and
  pointedToValue.getClass() = objectClass and
  
  // Exclude cases where type inference failed
  not Types::failedInference(objectClass, _) and
  
  // Verify the class lacks container-like capabilities
  not objectClass.hasAttribute("__contains__") and
  not objectClass.hasAttribute("__iter__") and
  not objectClass.hasAttribute("__getitem__") and
  
  // Exclude special types that might appear as containers
  not objectClass = ClassValue::nonetype() and
  not objectClass = Value::named("types.MappingProxyType")
select 
  comparisonExpr, 
  "This test may raise an Exception as the $@ may be of non-container class $@.", 
  sourceNode, "target", objectClass, objectClass.getName()