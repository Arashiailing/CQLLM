/**
 * @name Membership test with non-container operand
 * @description Identifies membership operations (e.g., 'x in y') where the right-hand operand
 *              lacks container properties, potentially causing runtime TypeError.
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

// Predicate identifying right-hand operands in membership comparisons
predicate isMembershipTestRhs(ControlFlowNode rhsNode, Compare comparisonExpr) {
  exists(Cmpop op, int operandIdx | 
    comparisonExpr.getOp(operandIdx) = op and 
    comparisonExpr.getComparator(operandIdx) = rhsNode.getNode()
  |
    op instanceof In or op instanceof NotIn
  )
}

from 
  ControlFlowNode rhsOperand, 
  Compare comparisonExpr, 
  Value pointedValue, 
  ClassValue valueClass, 
  ControlFlowNode originNode
where
  // Identify membership test operations
  isMembershipTestRhs(rhsOperand, comparisonExpr) and
  
  // Resolve actual value through data flow
  rhsOperand.pointsTo(_, pointedValue, originNode) and
  
  // Obtain class of the pointed value
  pointedValue.getClass() = valueClass and
  
  // Exclude valid container types and special cases
  not (
    // Handle type inference failures
    Types::failedInference(valueClass, _) or
    
    // Check for container protocol implementations
    valueClass.hasAttribute("__contains__") or
    valueClass.hasAttribute("__iter__") or
    valueClass.hasAttribute("__getitem__") or
    
    // Exclude known non-container types
    valueClass = ClassValue::nonetype() or
    valueClass = Value::named("types.MappingProxyType")
  )
select 
  comparisonExpr, 
  "This membership test may raise an Exception as the $@ might be of non-container type $@.", 
  originNode, "target", 
  valueClass, valueClass.getName()