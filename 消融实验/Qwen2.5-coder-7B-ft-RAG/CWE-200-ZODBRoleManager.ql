/**
 * @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * @description Exposing sensitive information in clear text could enable unauthorized access to the data.
 * @kind problem
 * @problem.severity warning
 * @security-severity 9.1
 * @precision high
 * @id py/CleartextStorageQuery
 * @tags security
 *       external/cwe/cwe-200
 */

import python
import semmle.python.security.dataflow.CleartextStorageQuery
import CleartextStorageFlow::PathGraph

from CleartextStorageFlow::PathNode source, CleartextStorageFlow::PathNode sink
where CleartextStorageFlow::flowPath(source, sink)
select sink, source, sink, "Data flow from $@ to $@ crosses a storage operation.", source,
  source.getNode(), sink, sink.getNode()