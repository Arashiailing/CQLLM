/**
 * @name Type inference fails for 'object'
 * @description Identifies instances where type inference is incomplete for 'object' types,
 *              which may reduce security analysis recall. This occurs when control flow nodes
 *              reference objects without full type specification (missing the 3-argument form).
 * @kind problem
 * @problem.severity info
 * @id py/type-inference-failure
 * @deprecated
 */

import python

from ControlFlowNode cfNode, Object objectRef
where 
  // Locate control flow nodes that reference objects
  cfNode.refersTo(objectRef) 
  // Filter out nodes with complete type information (3-argument form)
  and not cfNode.refersTo(objectRef, _, _)
select objectRef, "Type inference fails for 'object'."