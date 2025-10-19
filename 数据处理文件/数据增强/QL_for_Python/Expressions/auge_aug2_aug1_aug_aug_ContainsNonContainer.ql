/**
 * @name Membership test with non-container type
 * @description Identifies membership operations ('in'/'not in') where the right-hand operand
 *              lacks container capabilities, potentially causing runtime TypeErrors.
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
 * Holds if `rightOperand` is the right-hand side of a membership test ('in' or 'not in')
 * within the comparison expression `comparison`.
 * @param rightOperand - The control flow node evaluated as the right operand.
 * @param comparison - The comparison expression containing the membership test.
 */
predicate isRightOperandOfMembershipTest(ControlFlowNode rightOperand, Compare comparison) {
  exists(Cmpop op, int idx |
    comparison.getOp(idx) = op and 
    comparison.getComparator(idx) = rightOperand.getNode() and
    (op instanceof In or op instanceof NotIn)
  )
}

from 
  ControlFlowNode rightOperand, 
  Compare comparison, 
  Value targetValue, 
  ClassValue nonContainerClass, 
  ControlFlowNode sourceNode
where
  // Identify membership test right operand
  isRightOperandOfMembershipTest(rightOperand, comparison) and
  
  // Resolve type information through points-to analysis
  rightOperand.pointsTo(_, targetValue, sourceNode) and
  targetValue.getClass() = nonContainerClass and
  
  // Exclude cases with incomplete type inference
  not Types::failedInference(nonContainerClass, _) and
  
  // Verify absence of container interface methods
  (not nonContainerClass.hasAttribute("__contains__") and
   not nonContainerClass.hasAttribute("__iter__") and
   not nonContainerClass.hasAttribute("__getitem__")) and
  
  // Filter out pseudo-container types
  (not nonContainerClass = ClassValue::nonetype() and
   not nonContainerClass = Value::named("types.MappingProxyType"))
select 
  comparison, 
  "This membership test may raise an Exception because $@ might be of non-container class $@.", 
  sourceNode, "target", nonContainerClass, nonContainerClass.getName()