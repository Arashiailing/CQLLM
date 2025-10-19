/**
 * @name Cleartext storage of sensitive information
 * @description Storing sensitive information in cleartext can allow attackers to access this information without authorization.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 7.5
 * @precision medium
 * @id py/cleartext-storage
 * @tags security
 *       external/cwe/cwe-312
 */

import python
import semmle.python.security.dataflow.CleartextStorageQuery
import CleartextStorageFlow::PathGraph

from CleartextStorageFlow::PathNode source, CleartextStorageFlow::PathNode sink
where CleartextStorageFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "The $@ stores a cleartext secret.", source.getNode(),
  "cleartext value"