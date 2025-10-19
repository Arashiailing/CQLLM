/**
 * @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.5
 * @precision medium
 * @id py/cleartext-storage
 * @tags security
 *       external/cwe/cwe-200
 */

import python
import semmle.python.dataflow.new.DataFlow
import CleartextStorageFlow::PathGraph

from CleartextStorageFlow::PathNode dataFlowNode, string descriptionString
where
  exists(CleartextStorageFlow::PathNode source |
    CleartextStorageFlow::flowPath(source, dataFlowNode)
    and
    (
      source.getNode().(Sink).getKind() = "SensitiveData"
      and
      descriptionString = "sensitive data"
      or
      source.getNode().(Sink).getKind() = "Password"
      and
      descriptionString = "password"
    )
  )
select dataFlowNode.getNode(), source, dataFlowNode, "Storing $@ without encryption.", descriptionString