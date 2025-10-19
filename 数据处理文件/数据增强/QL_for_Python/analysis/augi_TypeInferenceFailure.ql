/**
 * @name Type inference fails for 'object'
 * @description Identifies cases where type inference fails for 'object', reducing recall in many queries.
 * @kind problem
 * @problem.severity info
 * @id py/type-inference-failure
 * @deprecated
 */

// Import Python module for code analysis
import python

// Select control flow nodes and objects meeting specific conditions
from ControlFlowNode node, Object targetObj
where
  // Condition 1: Node directly references the object
  node.refersTo(targetObj) and
  // Condition 2: Node lacks additional reference metadata
  not node.refersTo(targetObj, _, _)
// Report the target object with diagnostic message
select targetObj, "Type inference fails for 'object'."