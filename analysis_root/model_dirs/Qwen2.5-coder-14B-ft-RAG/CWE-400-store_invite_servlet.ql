/**
 * @name CWE-400: Uncontrolled Resource Consumption
 * @description The product does not properly control the allocation and maintenance of a limited resource.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision medium
 * @id py/store_invite_servlet
 */

import python
import semmle.python.Concepts
import CleartextStorageFlow::PathGraph

from CleartextStorageFlow::PathNode source, CleartextStorageFlow::PathNode target, string label
where
  (
    // Detect flow from function arguments to storage locations
    CleartextStorageFlow::flowPath(source.asCfgNode(), target.asCfgNode()) and
    label = "uncontrolled resource"
  )
  or
  (
    // Detect direct flows from user input to storage locations
    CleartextStorageFlow::flowPath(source.asCfgNode(), target.asCfgNode()) and
    label = "uncontrolled resource"
  )
  or
  (
    // Detect propagation of uncontrolled resources through function calls
    CleartextStorageFlow::flowPath(source.asCfgNode(), target.asCfgNode()) and
    label = "propagated to " + source.getNode().(CallNode).getAnArg()
  )
select target.getNode(), source, target,
  "$@ reaches this cleartext storage location and could cause uncontrolled resource consumption.",
  source.getNode(), label