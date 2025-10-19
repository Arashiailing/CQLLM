/**
 * @name Type inference fails for 'object'
 * @description This query identifies cases where type inference fails for 'object' types, 
 *              potentially reducing recall in security analysis. The issue occurs when 
 *              control flow nodes reference objects without complete type information.
 * @kind problem
 * @problem.severity info
 * @id py/type-inference-failure
 * @deprecated
 */

import python

from ControlFlowNode flowNode, Object targetObject
where 
  // Step 1: Identify control flow nodes that reference objects
  flowNode.refersTo(targetObject) 
  // Step 2: Exclude nodes with complete type information (3-argument form)
  and not flowNode.refersTo(targetObject, _, _)
select targetObject, "Type inference fails for 'object'."