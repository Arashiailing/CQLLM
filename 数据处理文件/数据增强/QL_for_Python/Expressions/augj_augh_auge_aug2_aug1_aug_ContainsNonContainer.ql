/**
 * @name Membership test with a non-container
 * @description Identifies membership operations (e.g., 'item in sequence') where the right-hand side 
 *              is a non-container object, which would cause a runtime 'TypeError'.
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
 * Determines if a control flow node serves as the right-hand operand in an In/NotIn comparison.
 * @param rhsNode - The control flow node being evaluated as the right operand
 * @param membershipExpr - The comparison expression containing the membership test
 */
predicate isRhsOperandInMembershipTest(ControlFlowNode rhsNode, Compare membershipExpr) {
  exists(Cmpop membershipOp, int opIndex |
    membershipExpr.getOp(opIndex) = membershipOp and 
    membershipExpr.getComparator(opIndex) = rhsNode.getNode() and
    (membershipOp instanceof In or membershipOp instanceof NotIn)
  )
}

from 
  ControlFlowNode rhsOperand, 
  Compare membershipExpr, 
  Value objectValue, 
  ClassValue objectClass, 
  ControlFlowNode originNode
where
  // Identify membership test operations (e.g., 'x in y' or 'x not in y')
  isRhsOperandInMembershipTest(rhsOperand, membershipExpr) and
  
  // Resolve the value of the right operand and determine its class
  rhsOperand.pointsTo(_, objectValue, originNode) and
  objectValue.getClass() = objectClass and
  
  // Exclude cases where type inference failed to prevent false positives
  not Types::failedInference(objectClass, _) and
  
  // Confirm the class lacks container capabilities
  // A proper container should implement at least one of these methods
  (not objectClass.hasAttribute("__contains__") and
   not objectClass.hasAttribute("__iter__") and
   not objectClass.hasAttribute("__getitem__")) and
  
  // Exclude special types that might behave like containers
  // NoneType and MappingProxyType are exceptions that might not implement
  // standard container methods but still support membership tests
  (objectClass != ClassValue::nonetype() and
   objectClass != Value::named("types.MappingProxyType"))
select 
  membershipExpr, 
  "This membership test may raise an Exception because the $@ could be of non-container class $@.", 
  originNode, "target", objectClass, objectClass.getName()