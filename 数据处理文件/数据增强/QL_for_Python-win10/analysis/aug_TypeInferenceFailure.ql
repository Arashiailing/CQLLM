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

from ControlFlowNode controlFlowNode, Object obj
where 
  // Identify control flow nodes referencing objects
  controlFlowNode.refersTo(obj) 
  // Exclude nodes with complete type references (3-argument form)
  and not controlFlowNode.refersTo(obj, _, _)
select obj, "Type inference fails for 'object'."