/**
 * @name Type inference fails for 'object'
 * @description Detects instances where type inference is incomplete for 'object' types,
 *              which may limit the effectiveness of security analysis
 * @kind problem
 * @problem.severity info
 * @id py/type-inference-failure
 * @deprecated
 */

// Import Python analysis framework for AST and control flow graph support
import python

// Find control flow nodes and associated objects with incomplete type information
from ControlFlowNode cfNode, Object targetObject
where
  // Check if the control flow node references the target object
  cfNode.refersTo(targetObject) and
  // Ensure no additional reference context is available (indicating incomplete inference)
  not cfNode.refersTo(targetObject, _, _)
// Report the affected object with a descriptive message
select targetObject, "Type inference fails for 'object'."