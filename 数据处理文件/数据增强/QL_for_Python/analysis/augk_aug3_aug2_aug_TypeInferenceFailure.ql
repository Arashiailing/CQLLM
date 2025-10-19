/**
 * @name Type inference fails for 'object'
 * @description Detects code locations where type inference for 'object' types is incomplete.
 *              This limitation hinders security analysis by restricting data flow tracking
 *              and compromising type relationship precision. The problem manifests when
 *              control flow nodes utilize the basic 1-argument refersTo() predicate
 *              instead of the detailed 3-argument version that includes full type context.
 * @kind problem
 * @problem.severity info
 * @id py/type-inference-failure
 * @deprecated
 */

import python

from ControlFlowNode flowNode, Object targetObject
where 
  // Check if the node references an object using the simplified form
  flowNode.refersTo(targetObject) 
  // Ensure the node does NOT use the comprehensive form with type information
  and not flowNode.refersTo(targetObject, _, _)
select targetObject, "Type inference fails for 'object'."