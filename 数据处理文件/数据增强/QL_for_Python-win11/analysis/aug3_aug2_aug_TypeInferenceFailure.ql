/**
 * @name Type inference fails for 'object'
 * @description Identifies instances where type inference is incomplete for 'object' types.
 *              This deficiency can impact security analysis by limiting data flow tracking
 *              and type relationship accuracy. The issue occurs when control flow nodes
 *              reference objects using the simplified 1-argument refersTo() instead of
 *              the comprehensive 3-argument form that includes complete type information.
 * @kind problem
 * @problem.severity info
 * @id py/type-inference-failure
 * @deprecated
 */

import python

from ControlFlowNode ctrlFlowNode, Object referencedObject
where 
  // Verify node references object using simplified single-argument form
  ctrlFlowNode.refersTo(referencedObject) 
  // Confirm absence of comprehensive three-argument form with type details
  and not ctrlFlowNode.refersTo(referencedObject, _, _)
select referencedObject, "Type inference fails for 'object'."