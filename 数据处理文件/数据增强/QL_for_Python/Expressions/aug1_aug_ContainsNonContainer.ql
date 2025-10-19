/**
 * @name Membership test with a non-container
 * @description Detects membership tests (e.g., 'item in sequence') where the right-hand side 
 *              is a non-container object, which would raise a 'TypeError' at runtime.
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
 * Identifies nodes serving as right operands in In/NotIn comparisons.
 * @param node - Control flow node being evaluated
 * @param cmpNode - Comparison expression containing the operation
 */
predicate isRhsOfInTest(ControlFlowNode node, Compare cmpNode) {
  exists(Cmpop op, int idx |
    cmpNode.getOp(idx) = op and 
    cmpNode.getComparator(idx) = node.getNode() and
    (op instanceof In or op instanceof NotIn)
  )
}

from 
  ControlFlowNode rhsNode, 
  Compare cmpExpr, 
  Value pointedToValue, 
  ClassValue cls, 
  ControlFlowNode origin
where
  // Confirm node is right operand in membership test
  isRhsOfInTest(rhsNode, cmpExpr) and
  
  // Resolve node's value and class
  rhsNode.pointsTo(_, pointedToValue, origin) and
  pointedToValue.getClass() = cls and
  
  // Skip cases with failed type inference
  not Types::failedInference(cls, _) and
  
  // Verify absence of container capabilities
  not cls.hasAttribute("__contains__") and
  not cls.hasAttribute("__iter__") and
  not cls.hasAttribute("__getitem__") and
  
  // Exclude special container-like types
  not cls = ClassValue::nonetype() and
  not cls = Value::named("types.MappingProxyType")
select 
  cmpExpr, 
  "This test may raise an Exception as the $@ may be of non-container class $@.", 
  origin, "target", cls, cls.getName()