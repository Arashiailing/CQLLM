/**
 * @name Non-container membership test detection
 * @description Identifies membership operations (e.g., 'item in sequence') where the right-hand operand 
 *              is a non-container object. Such operations raise 'TypeError' at runtime since non-container 
 *              objects lack membership support methods.
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

// Extracts right-hand operand from In/NotIn comparison operations
predicate get_membership_rhs(ControlFlowNode rhsOperand, Compare cmpNode) {
  exists(Cmpop op, int idx | 
    cmpNode.getOp(idx) = op and 
    cmpNode.getComparator(idx) = rhsOperand.getNode() and 
    (op instanceof In or op instanceof NotIn)
  )
}

from ControlFlowNode rhsOperand, Compare cmpNode, Value resolvedValue, ClassValue targetClass, ControlFlowNode origin
where
  // Step 1: Identify membership test operations
  get_membership_rhs(rhsOperand, cmpNode) and
  // Step 2: Resolve value and trace its origin
  rhsOperand.pointsTo(_, resolvedValue, origin) and
  // Step 3: Determine the class of the resolved value
  resolvedValue.getClass() = targetClass and
  // Step 4: Filter out cases with failed type inference
  not Types::failedInference(targetClass, _) and
  // Step 5: Exclude classes with container-like capabilities
  not (
    targetClass.hasAttribute("__contains__") or
    targetClass.hasAttribute("__iter__") or
    targetClass.hasAttribute("__getitem__")
  ) and
  // Step 6: Exclude specific known container types
  not targetClass = ClassValue::nonetype() and
  not targetClass = Value::named("types.MappingProxyType")
select cmpNode, "This test may raise an Exception as the $@ may be of non-container class $@.", origin,
  "target", targetClass, targetClass.getName()