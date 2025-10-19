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

from ControlFlowNode node, Object obj
where 
  // Node references object using simplified form without type information
  node.refersTo(obj) 
  // Node does not use comprehensive form with complete type details
  and not node.refersTo(obj, _, _)
select obj, "Type inference fails for 'object'."