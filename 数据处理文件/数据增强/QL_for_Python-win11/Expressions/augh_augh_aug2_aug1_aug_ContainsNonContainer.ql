/**
 * @name Membership test with non-container object
 * @description Detects membership operations (e.g., 'item in sequence') where the right-hand operand 
 *              is a non-container object, causing runtime 'TypeError'.
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
 * @param rhsNode - Control flow node representing the right operand
 * @param compNode - Comparison expression containing the membership test
 */
predicate isRhsOfInTest(ControlFlowNode rhsNode, Compare compNode) {
  exists(Cmpop op, int idx |
    compNode.getOp(idx) = op and 
    compNode.getComparator(idx) = rhsNode.getNode() and
    (op instanceof In or op instanceof NotIn)
  )
}

from 
  ControlFlowNode rightOperand, 
  Compare comparisonExpr, 
  Value pointedToValue, 
  ClassValue valueClass, 
  ControlFlowNode sourceNode
where
  // Identify membership test right operand
  isRhsOfInTest(rightOperand, comparisonExpr) and
  
  // Resolve value and type information
  rightOperand.pointsTo(_, pointedToValue, sourceNode) and
  pointedToValue.getClass() = valueClass and
  
  // Exclude cases with incomplete type analysis
  not Types::failedInference(valueClass, _) and
  
  // Verify absence of container interface methods
  (
    not valueClass.hasAttribute("__contains__") and
    not valueClass.hasAttribute("__iter__") and
    not valueClass.hasAttribute("__getitem__")
  ) and
  
  // Exclude special container-like types
  (
    not valueClass = ClassValue::nonetype() and
    not valueClass = Value::named("types.MappingProxyType")
  )
select 
  comparisonExpr, 
  "This membership test may raise an Exception because the $@ is of non-container type $@.", 
  sourceNode, "target", valueClass, valueClass.getName()