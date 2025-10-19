/**
 * @name Type inference fails for 'object'
 * @description Identifies instances where type inference is incomplete for object types.
 *              This limitation affects security analysis by reducing precision in
 *              data flow tracking and type relationship analysis. The issue manifests
 *              when control flow nodes reference objects using the simplified
 *              single-argument refersTo() method rather than the comprehensive three-argument
 *              variant that includes complete type information.
 * @kind problem
 * @problem.severity info
 * @id py/type-inference-failure
 * @deprecated
 */

import python

from ControlFlowNode node, Object targetObject
where 
  // Check if the node uses simplified object reference
  node.refersTo(targetObject) 
  // Ensure the node does not use comprehensive type-aware reference
  and not node.refersTo(targetObject, _, _)
select targetObject, "Type inference fails for 'object'."