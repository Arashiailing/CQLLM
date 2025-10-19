/**
 * @name Membership test with a non-container
 * @description Detects membership operations (e.g., 'item in sequence') where the right-hand operand 
 *              is a non-container object, causing a runtime 'TypeError'.
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
 * Identifies right operands in membership test operations.
 * @param operand - The control flow node being evaluated
 * @param comparison - The comparison expression containing the operation
 */
predicate isRhsOfInTest(ControlFlowNode operand, Compare comparison) {
  exists(Cmpop operator, int index |
    comparison.getOp(index) = operator and 
    comparison.getComparator(index) = operand.getNode() and
    (operator instanceof In or operator instanceof NotIn)
  )
}

from 
  ControlFlowNode rhsOperand, 
  Compare comparisonNode, 
  Value pointedValue, 
  ClassValue objectClass, 
  ControlFlowNode originNode
where
  // Verify membership test context
  isRhsOfInTest(rhsOperand, comparisonNode) and
  
  // Resolve object type information
  rhsOperand.pointsTo(_, pointedValue, originNode) and
  pointedValue.getClass() = objectClass and
  
  // Exclude cases with incomplete type analysis
  not Types::failedInference(objectClass, _) and
  
  // Confirm absence of container interface methods
  not objectClass.hasAttribute("__contains__") and
  not objectClass.hasAttribute("__iter__") and
  not objectClass.hasAttribute("__getitem__") and
  
  // Exclude special container-like types
  not objectClass = ClassValue::nonetype() and
  not objectClass = Value::named("types.MappingProxyType")
select 
  comparisonNode, 
  "This test may raise an Exception as the $@ may be of non-container class $@.", 
  originNode, "target", objectClass, objectClass.getName()