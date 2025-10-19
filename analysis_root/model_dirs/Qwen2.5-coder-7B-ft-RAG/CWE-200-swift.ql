/**
 * @name Cleartext Logging Query
 * @description Detects potential logging of sensitive data without encryption, exposing it to unauthorized access.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 5.0
 * @precision high
 * @id py/swift
 * @tags security
 *       external/cwe/cwe-200
 */

import python
import semmle.python.security.dataflow.CleartextLoggingQuery
import CleartextLoggingFlow::PathGraph

from CleartextLoggingFlow::PathNode taintedNode, CleartextLoggingFlow::PathNode sinkNode
where CleartextLoggingFlow::flowPath(taintedNode, sinkNode)
select sinkNode.getNode(), taintedNode, sinkNode, "Data flow from $@ to this point.", taintedNode.getNode(),
  "unencrypted sensitive data"