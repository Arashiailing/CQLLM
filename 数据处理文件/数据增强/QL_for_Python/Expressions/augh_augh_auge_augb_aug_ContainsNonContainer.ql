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
 * Identifies nodes serving as the right-hand operand in membership test expressions (In/NotIn).
 * @param rightOperand - The control flow node being examined as the right operand
 * @param comparisonNode - The comparison expression performing the membership test
 */
predicate isRightOperandInMembershipTest(ControlFlowNode rightOperand, Compare comparisonNode) {
  exists(Cmpop operator, int index |
    comparisonNode.getOp(index) = operator and 
    comparisonNode.getComparator(index) = rightOperand.getNode() and
    (operator instanceof In or operator instanceof NotIn)
  )
}

from 
  ControlFlowNode rightOperandNode, 
  Compare comparisonNode, 
  Value inferredValue, 
  ClassValue targetClass, 
  ControlFlowNode sourceNode
where
  // Locate membership test expressions and extract their right operand
  isRightOperandInMembershipTest(rightOperandNode, comparisonNode) and
  
  // Perform type analysis on the right operand to determine its class
  rightOperandNode.pointsTo(_, inferredValue, sourceNode) and
  inferredValue.getClass() = targetClass and
  
  // Verify that type inference was successful
  not Types::failedInference(targetClass, _) and
  
  // Check if the class lacks essential container methods and isn't a recognized container type
  (not targetClass.hasAttribute("__contains__") and
   not targetClass.hasAttribute("__iter__") and
   not targetClass.hasAttribute("__getitem__")) and
  not targetClass = ClassValue::nonetype() and
  not targetClass = Value::named("types.MappingProxyType")
select 
  comparisonNode, 
  "This membership test may raise an Exception because the $@ could be an instance of non-container class $@.", 
  sourceNode, "target", targetClass, targetClass.getName()