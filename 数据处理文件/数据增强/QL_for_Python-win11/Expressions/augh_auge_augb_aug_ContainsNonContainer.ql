/**
 * @name Non-container membership test detection
 * @description Identifies membership checks (e.g., 'element in collection') where the collection 
 *              operand is a non-container type, potentially causing runtime 'TypeError'.
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
 * Locates nodes that function as the right-hand side in membership testing expressions (In/NotIn).
 * @param rhsOperand - The control flow node being examined as the right operand
 * @param comparisonExpr - The comparison expression that performs the membership test
 */
predicate isRightOperandInMembershipTest(ControlFlowNode rhsOperand, Compare comparisonExpr) {
  exists(Cmpop operator, int index |
    comparisonExpr.getOp(index) = operator and 
    comparisonExpr.getComparator(index) = rhsOperand.getNode() and
    (operator instanceof In or operator instanceof NotIn)
  )
}

from 
  ControlFlowNode rhsOperandNode, 
  Compare comparisonExpr, 
  Value resolvedValue, 
  ClassValue operandClass, 
  ControlFlowNode originNode
where
  // Find membership test expressions and extract their right operand
  isRightOperandInMembershipTest(rhsOperandNode, comparisonExpr) and
  
  // Perform type analysis on the right operand to determine its class
  rhsOperandNode.pointsTo(_, resolvedValue, originNode) and
  resolvedValue.getClass() = operandClass and
  
  // Verify that type inference was successful
  not Types::failedInference(operandClass, _) and
  
  // Determine if the class lacks essential container methods and is not a recognized container type
  (not operandClass.hasAttribute("__contains__") and
   not operandClass.hasAttribute("__iter__") and
   not operandClass.hasAttribute("__getitem__")) and
  not operandClass = ClassValue::nonetype() and
  not operandClass = Value::named("types.MappingProxyType")
select 
  comparisonExpr, 
  "This membership test may raise an Exception because the $@ could be an instance of non-container class $@.", 
  originNode, "target", operandClass, operandClass.getName()