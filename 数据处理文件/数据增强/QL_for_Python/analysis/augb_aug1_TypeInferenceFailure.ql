/**
 * @name Type inference fails for 'object'
 * @description Detects instances where type inference is incomplete for 'object' types,
 *              which may limit the effectiveness of security analysis
 * @kind problem
 * @problem.severity info
 * @id py/type-inference-failure
 * @deprecated
 */

// Import Python analysis framework for examining Python code structures
import python

// Identify control flow nodes and objects with incomplete type inference
from ControlFlowNode cfNode, Object targetObj
where
  // The control flow node has a direct reference to the object
  cfNode.refersTo(targetObj) and
  // The object lacks additional reference context information
  not cfNode.refersTo(targetObj, _, _)
// Output the affected object along with a diagnostic message
select targetObj, "Type inference fails for 'object'."