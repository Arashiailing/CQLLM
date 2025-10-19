/**
 * @name Type inference fails for 'object'
 * @description This query identifies 'object' instances where type inference is unsuccessful,
 *              potentially leading to reduced recall in various analyses.
 * @kind problem
 * @id py/type-inference-failure
 * @deprecated
 */

import python

from ControlFlowNode node, Object instance
where
  // The control flow node refers to the object instance
  node.refersTo(instance) and
  // The control flow node does not refer to the object instance with additional parameters
  not node.refersTo(instance, _, _)
select instance, "Type inference fails for 'object'."