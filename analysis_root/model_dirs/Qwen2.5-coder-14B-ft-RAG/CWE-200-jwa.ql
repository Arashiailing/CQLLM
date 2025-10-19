/**
 * @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * @description nan
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision medium
 * @id py/jwa
 * @tags security
 *       external/cwe/cwe-200
 */

import python
import semmle.python.security.dataflow.CleartextStorageQuery
import CleartextStorageFlow::PathGraph

from
  CleartextStorageFlow::PathNode source,
  CleartextStorageFlow::PathNode sink
where
  CleartextStorageFlow::flowPath(source, sink)
select
  sink.getNode(),
  source,
  sink,
  "$@ flows to this location and is stored insecurely.", // warning message
  source.getNode(),
  "User controlled data"