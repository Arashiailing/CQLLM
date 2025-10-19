/**
 * @name Non-container in membership test
 * @description Detects membership tests (e.g., 'item in sequence') where the right-hand side 
 *              is a non-container object, leading to a runtime 'TypeError'.
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
 * Holds when `rhsNode` is the right operand of an 'in' or 'not in' comparison in `cmpExpr`.
 * @param rhsNode - The control flow node that is the right operand.
 * @param cmpExpr - The comparison expression containing the operation.
 */
predicate isRhsOfInTest(ControlFlowNode rhsNode, Compare cmpExpr) {
  exists(Cmpop op, int idx |
    cmpExpr.getOp(idx) = op and 
    cmpExpr.getComparator(idx) = rhsNode.getNode() and
    (op instanceof In or op instanceof NotIn)
  )
}

from 
  ControlFlowNode rhsNode, 
  Compare cmpExpr, 
  Value pointedToValue, 
  ClassValue valueType, 
  ControlFlowNode originNode
where
  // Check that the node is the right operand in a membership test
  isRhsOfInTest(rhsNode, cmpExpr) and
  
  // Obtain the value and its type information
  rhsNode.pointsTo(_, pointedToValue, originNode) and
  pointedToValue.getClass() = valueType and
  
  // Skip cases where type inference failed
  not Types::failedInference(valueType, _) and
  
  // Ensure the type does not have container-like attributes
  not valueType.hasAttribute("__contains__") and
  not valueType.hasAttribute("__iter__") and
  not valueType.hasAttribute("__getitem__") and
  
  // Exclude special types that might be container-like but we don't want to flag
  not valueType = ClassValue::nonetype() and
  not valueType = Value::named("types.MappingProxyType")
select 
  cmpExpr, 
  "This test may raise an Exception as the $@ may be of non-container class $@.", 
  originNode, "target", valueType, valueType.getName()