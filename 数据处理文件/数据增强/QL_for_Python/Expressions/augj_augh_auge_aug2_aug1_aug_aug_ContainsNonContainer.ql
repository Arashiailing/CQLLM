/**
 * @name Membership test with non-container type
 * @description Detects membership tests ('in'/'not in') where the right-hand side is not a container type,
 *              which can lead to runtime TypeErrors.
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

from 
  ControlFlowNode rightHandSideNode, 
  Compare comparisonExpr, 
  Value inferredTypeValue, 
  ClassValue nonContainerClass, 
  ControlFlowNode sourceNode
where
  // Step 1: Identify membership test operation and extract right operand
  exists(Cmpop op, int idx |
    comparisonExpr.getOp(idx) = op and 
    comparisonExpr.getComparator(idx) = rightHandSideNode.getNode() and
    (op instanceof In or op instanceof NotIn)
  ) and
  
  // Step 2: Perform points-to analysis to determine the type of the right operand
  rightHandSideNode.pointsTo(_, inferredTypeValue, sourceNode) and
  inferredTypeValue.getClass() = nonContainerClass and
  
  // Step 3: Filter out cases with incomplete type inference results
  not Types::failedInference(nonContainerClass, _) and
  
  // Step 4: Verify the class lacks essential container interface methods
  (not nonContainerClass.hasAttribute("__contains__") and
   not nonContainerClass.hasAttribute("__iter__") and
   not nonContainerClass.hasAttribute("__getitem__")) and
  
  // Step 5: Exclude known pseudo-container types from triggering false positives
  (not nonContainerClass = ClassValue::nonetype() and
   not nonContainerClass = Value::named("types.MappingProxyType"))
select 
  comparisonExpr, 
  "This membership test may raise an Exception because $@ might be of non-container class $@.", 
  sourceNode, "target", nonContainerClass, nonContainerClass.getName()