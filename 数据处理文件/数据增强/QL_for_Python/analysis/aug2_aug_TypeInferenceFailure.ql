/**
 * @name Type inference fails for 'object'
 * @description Identifies instances where type inference is incomplete for 'object' types.
 *              This deficiency can impact the effectiveness of security analysis by limiting
 *              the ability to accurately track data flow and type relationships. The issue
 *              manifests when control flow nodes make reference to objects using the simplified
 *              1-argument form of refersTo() rather than the comprehensive 3-argument form
 *              which includes complete type information.
 * @kind problem
 * @problem.severity info
 * @id py/type-inference-failure
 * @deprecated
 */

import python

from ControlFlowNode flowNode, Object targetObj
where 
  // Check if the control flow node references an object using the simple form
  flowNode.refersTo(targetObj) 
  // Ensure the node does NOT use the comprehensive 3-argument form with type information
  and not flowNode.refersTo(targetObj, _, _)
select targetObj, "Type inference fails for 'object'."