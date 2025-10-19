/**
 * @name Membership test with a non-container
 * @description A membership test, such as 'item in sequence', with a non-container 
 *              on the right hand side will raise a 'TypeError'.
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

// Identifies Compare nodes containing In/NotIn operations where the specified node 
// serves as the right-hand operand in membership testing
predicate isRightOperandInMembershipTest(ControlFlowNode rhsNode, Compare membershipTest) {
  exists(Cmpop op, int i | 
    membershipTest.getOp(i) = op and 
    membershipTest.getComparator(i) = rhsNode.getNode() and 
    (op instanceof In or op instanceof NotIn)
  )
}

from 
  ControlFlowNode nonContainerRhsNode, 
  Compare membershipTest, 
  Value pointedValue, 
  ClassValue valueClass, 
  ControlFlowNode sourceNode
where
  // Establish relationship between membership test and its right operand
  isRightOperandInMembershipTest(nonContainerRhsNode, membershipTest) and
  
  // Track value flow and class information
  nonContainerRhsNode.pointsTo(_, pointedValue, sourceNode) and
  pointedValue.getClass() = valueClass and
  
  // Exclude cases with failed type inference
  not Types::failedInference(valueClass, _) and
  
  // Verify absence of container protocol methods
  not valueClass.hasAttribute("__contains__") and
  not valueClass.hasAttribute("__iter__") and
  not valueClass.hasAttribute("__getitem__") and
  
  // Exclude special container-like types
  not valueClass = ClassValue::nonetype() and
  not valueClass = Value::named("types.MappingProxyType")
select 
  membershipTest, 
  "This test may raise an Exception as the $@ may be of non-container class $@.", 
  sourceNode, "target", valueClass, valueClass.getName()