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
 * Identifies right-hand operands in membership testing expressions (In/NotIn).
 * @param rhsNode - Control flow node being examined as the right operand
 * @param cmpExpr - Comparison expression performing the membership test
 */
predicate isRightOperandInMembershipTest(ControlFlowNode rhsNode, Compare cmpExpr) {
  exists(Cmpop op, int idx |
    cmpExpr.getOp(idx) = op and 
    cmpExpr.getComparator(idx) = rhsNode.getNode() and
    (op instanceof In or op instanceof NotIn)
  )
}

from 
  ControlFlowNode rightOperand, 
  Compare membershipTest, 
  Value inferredValue, 
  ClassValue typeClass, 
  ControlFlowNode origin
where
  // Identify membership test expressions and extract their right operand
  isRightOperandInMembershipTest(rightOperand, membershipTest) and
  
  // Perform type analysis on the right operand to determine its class
  rightOperand.pointsTo(_, inferredValue, origin) and
  inferredValue.getClass() = typeClass and
  
  // Ensure type inference was successful
  not Types::failedInference(typeClass, _) and
  
  // Verify the class lacks essential container methods
  not (typeClass.hasAttribute("__contains__") or 
       typeClass.hasAttribute("__iter__") or 
       typeClass.hasAttribute("__getitem__")) and
  // Exclude recognized non-container types
  not typeClass = ClassValue::nonetype() and
  not typeClass = Value::named("types.MappingProxyType")
select 
  membershipTest, 
  "This membership test may raise an Exception because the $@ could be an instance of non-container class $@.", 
  origin, "target", typeClass, typeClass.getName()