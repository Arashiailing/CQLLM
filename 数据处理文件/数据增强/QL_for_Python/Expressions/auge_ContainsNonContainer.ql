/**
 * @name Membership test with a non-container
 * @description Detects membership tests (e.g., 'item in sequence') where the right-hand side
 *              is not a container type, which will raise a 'TypeError' at runtime.
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

// Predicate to identify RHS operands of 'In' or 'NotIn' operations
predicate isRhsOfMembershipTest(ControlFlowNode rhsNode, Compare comparisonNode) {
  exists(Cmpop op, int operandIndex | 
    comparisonNode.getOp(operandIndex) = op and 
    comparisonNode.getComparator(operandIndex) = rhsNode.getNode()
  |
    op instanceof In or op instanceof NotIn
  )
}

from 
  ControlFlowNode nonContainerNode, 
  Compare comparisonNode, 
  Value pointedValue, 
  ClassValue valueClass, 
  ControlFlowNode originNode
where
  // Identify membership test operations
  isRhsOfMembershipTest(nonContainerNode, comparisonNode) and
  
  // Track data flow to identify the actual value
  nonContainerNode.pointsTo(_, pointedValue, originNode) and
  
  // Get the class of the pointed value
  pointedValue.getClass() = valueClass and
  
  // Exclude cases where:
  not (
    // Type inference failed
    Types::failedInference(valueClass, _) or
    
    // Class implements container protocols
    valueClass.hasAttribute("__contains__") or
    valueClass.hasAttribute("__iter__") or
    valueClass.hasAttribute("__getitem__") or
    
    // Special non-container types
    valueClass = ClassValue::nonetype() or
    valueClass = Value::named("types.MappingProxyType")
  )
select 
  comparisonNode, 
  "This test may raise an Exception as the $@ may be of non-container class $@.", 
  originNode, "target", 
  valueClass, valueClass.getName()