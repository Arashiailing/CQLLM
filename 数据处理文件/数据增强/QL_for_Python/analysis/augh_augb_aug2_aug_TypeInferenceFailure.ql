/**
 * @name Type inference fails for 'object'
 * @description Identifies locations where type inference is incomplete for object types.
 *              This limitation impacts security analysis by reducing precision in data flow
 *              tracking and type relationship analysis. The issue manifests when control flow
 *              nodes reference objects using the simplified single-argument refersTo() method
 *              instead of the comprehensive three-argument form that includes complete type
 *              information.
 * @kind problem
 * @problem.severity info
 * @id py/type-inference-failure
 * @deprecated
 */

import python

from ControlFlowNode controlFlowNode, Object referencedObject
where 
  // A control flow node is problematic if it meets both conditions:
  // 1. It uses the simplified object reference form
  controlFlowNode.refersTo(referencedObject) 
  // 2. It does not use the comprehensive type-aware reference form
  and not controlFlowNode.refersTo(referencedObject, _, _)
select referencedObject, "Type inference fails for 'object'."