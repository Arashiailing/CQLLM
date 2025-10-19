/**
 * @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * @description nan
 * @kind path-problem
 * @id py/keycloak_cli
 * @problem.severity error
 * @precision medium
 * @tags security
 *       external/cwe/cwe-200
 */

import python
import semmle.python.security.dataflow.CleartextStorageQuery
import CleartextStorageFlow::PathGraph

from
  CleartextStorageFlow::PathNode source,
  CleartextStorageFlow::PathNode sink,
  string kind
where
  CleartextStorageFlow::flowPath(source, sink)
  and
  kind = "plaintext"
select sink.getNode(),
  source, 
  sink,
  "This expression stores sensitive data as $@.", 
  source.getNode(), 
  kind