/**
 * @name Type inference fails for 'object'
 * @description Identifies instances where type inference is incomplete for 'object' types,
 *              which may reduce the effectiveness of security analysis. This occurs when
 *              control flow nodes reference objects but lack complete type information.
 * @kind problem
 * @problem.severity info
 * @id py/type-inference-failure
 * @deprecated
 */

import python

from ControlFlowNode cfNode, Object referencedObject
where 
  // The control flow node references an object
  cfNode.refersTo(referencedObject) 
  // But does not have complete type information (no type and location specified)
  and not cfNode.refersTo(referencedObject, _, _)
select referencedObject, "Type inference fails for 'object'."