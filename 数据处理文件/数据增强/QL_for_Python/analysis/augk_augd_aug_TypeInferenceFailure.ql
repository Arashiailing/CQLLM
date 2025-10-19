/**
 * @name Type inference fails for 'object'
 * @description Detects cases where type inference is incomplete for object instances,
 *              potentially reducing security analysis effectiveness. This pattern manifests
 *              when control flow nodes reference objects without utilizing the comprehensive
 *              3-argument type specification form.
 * @kind problem
 * @problem.severity info
 * @id py/type-inference-failure
 * @deprecated
 */

import python

from ControlFlowNode flowNode, Object objInstance
where 
  // Identify control flow nodes that have references to object instances
  flowNode.refersTo(objInstance) 
  // Exclude nodes that provide complete type information via 3-argument form
  and not flowNode.refersTo(objInstance, _, _)
select objInstance, "Type inference fails for 'object'."