/**
 * @name Type inference fails for 'object'
 * @description Detects cases where type inference is incomplete for object types.
 *              This limitation hinders security analysis by reducing precision in
 *              data flow tracking and type relationship analysis. The issue occurs
 *              when control flow nodes reference objects using the simplified
 *              single-argument refersTo() instead of the comprehensive three-argument
 *              form that includes complete type information.
 * @kind problem
 * @problem.severity info
 * @id py/type-inference-failure
 * @deprecated
 */

import python

from ControlFlowNode cfNode, Object obj
where 
  // Identify nodes using simplified object reference
  cfNode.refersTo(obj) 
  // Exclude nodes using comprehensive type-aware reference
  and not cfNode.refersTo(obj, _, _)
select obj, "Type inference fails for 'object'."