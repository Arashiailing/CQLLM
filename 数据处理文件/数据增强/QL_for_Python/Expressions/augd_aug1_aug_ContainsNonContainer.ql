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
 * Identifies nodes serving as right operands in membership tests (in/not in).
 * @param operandNode - Control flow node being evaluated as right-hand side
 * @param comparisonNode - Comparison expression containing the membership operation
 */
predicate isRightOperandInMembershipTest(ControlFlowNode operandNode, Compare comparisonNode) {
  exists(Cmpop operation, int index |
    comparisonNode.getOp(index) = operation and 
    comparisonNode.getComparator(index) = operandNode.getNode() and
    (operation instanceof In or operation instanceof NotIn)
  )
}

/**
 * Determines if a class has container-like capabilities by checking special methods.
 * @param targetClass - Class to evaluate for container capabilities
 * @returns true if class has at least one container method
 */
predicate hasContainerMethods(ClassValue targetClass) {
  targetClass.hasAttribute("__contains__") or
  targetClass.hasAttribute("__iter__") or
  targetClass.hasAttribute("__getitem__")
}

/**
 * Identifies special classes that should be excluded from analysis.
 * @param targetClass - Class to evaluate for exclusion
 * @returns true if class should be excluded from analysis
 */
predicate isExcludedContainerType(ClassValue targetClass) {
  targetClass = ClassValue::nonetype() or
  targetClass = Value::named("types.MappingProxyType")
}

from 
  ControlFlowNode rhsNode, 
  Compare comparisonExpr, 
  Value objectValue, 
  ClassValue valueClass, 
  ControlFlowNode sourceLocation
where
  // Verify node is right operand in membership test
  isRightOperandInMembershipTest(rhsNode, comparisonExpr) and
  
  // Resolve the value and class of the right operand
  rhsNode.pointsTo(_, objectValue, sourceLocation) and
  objectValue.getClass() = valueClass and
  
  // Skip cases where type inference failed
  not Types::failedInference(valueClass, _) and
  
  // Ensure class lacks container capabilities
  not hasContainerMethods(valueClass) and
  
  // Exclude special container-like types from analysis
  not isExcludedContainerType(valueClass)
select 
  comparisonExpr, 
  "This test may raise an Exception as the $@ may be of non-container class $@.", 
  sourceLocation, "target", valueClass, valueClass.getName()