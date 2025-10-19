/**
 * @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * @description Storing sensitive information insecurely exposes it to unauthorized access.
 * @kind problem
 * @problem.severity warning
 * @security-severity 8.1
 * @precision high
 * @id py/keycloak_cli
 * @tags security
 *       external/cwe/cwe-200
 */

import python
import semmle.python.security.dataflow.CleartextStorageQuery
import CleartextStorageFlow::PathGraph

from CleartextStorageFlow::PathNode source, CleartextStorageFlow::PathNode sink
where CleartextStorageFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "The data flow ends at this location because it stores $@.", source,
  "sensitive information"