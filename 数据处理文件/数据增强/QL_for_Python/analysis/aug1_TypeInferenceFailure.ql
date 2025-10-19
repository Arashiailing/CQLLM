/**
 * @name Type inference fails for 'object'
 * @description Identifies cases where type inference fails for 'object' types, 
 *              potentially reducing detection coverage in security queries
 * @kind problem
 * @problem.severity info
 * @id py/type-inference-failure
 * @deprecated
 */

// Import Python analysis library for processing Python code constructs
import python

// Select control flow nodes and objects where type inference is incomplete
from ControlFlowNode controlFlowNode, Object obj
where
  // Node directly references the object
  controlFlowNode.refersTo(obj) and
  // No additional reference context exists for this object
  not controlFlowNode.refersTo(obj, _, _)
// Report the affected object with diagnostic message
select obj, "Type inference fails for 'object'."