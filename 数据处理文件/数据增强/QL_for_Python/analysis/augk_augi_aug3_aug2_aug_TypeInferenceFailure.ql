/**
 * @name Type inference fails for 'object'
 * @description Detects cases where type inference is incomplete for 'object' types.
 *              This limitation can affect security analysis by restricting data flow tracking
 *              and precision in type relationships. The problem arises when control flow nodes
 *              refer to objects using the basic 1-argument refersTo() rather than
 *              the detailed 3-argument version that provides full type information.
 * @kind problem
 * @problem.severity info
 * @id py/type-inference-failure
 * @deprecated
 */

import python

from ControlFlowNode cfgNode, Object objectInstance
where 
  // Check if the control flow node references an object using the simplified form
  cfgNode.refersTo(objectInstance) 
  // Ensure the node doesn't use the comprehensive form with type details
  and not cfgNode.refersTo(objectInstance, _, _)
select objectInstance, "Type inference fails for 'object'."