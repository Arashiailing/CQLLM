/**
 * @name Type inference fails for 'object'
 * @description Identifies code locations where type inference is incomplete for 'object' types,
 *              potentially reducing the precision of security analysis
 * @kind problem
 * @problem.severity info
 * @id py/type-inference-failure
 * @deprecated
 */

// Import Python analysis framework to inspect Python code constructs
import python

// Define the criteria for incomplete type inference
from ControlFlowNode flowNode, Object inferredObject
where
  // Condition 1: Direct reference exists
  flowNode.refersTo(inferredObject) and
  // Condition 2: No extended reference context available
  not flowNode.refersTo(inferredObject, _, _)
// Present findings with appropriate diagnostic message
select inferredObject, "Type inference fails for 'object'."