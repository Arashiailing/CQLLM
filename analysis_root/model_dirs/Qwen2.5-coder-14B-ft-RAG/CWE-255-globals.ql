/**
 * @name Cleartext storage of sensitive information
 * @description Storing passwords and other sensitive information in clear text could expose it to unauthorized users.
 * @kind path-problem
 * @id py/clear-text-storage
 * @problem.severity error
 * @security-severity 7.5
 * @precision medium
 * @tags security
 *       external/cwe/cwe-312
 */

import python
import semmle.python.security.dataflow.CleartextStorageQuery
import CleartextStorageFlow::PathGraph

from CleartextStorageFlow::PathNode source, CleartextStorageFlow::PathNode sink
where CleartextStorageFlow::flowPath(source, sink)
select sink.getNode(), source, sink,
  "$@ is stored in a location where it can be accessed by anyone with access to this file.",
  source.getNode(), "Sensitive data (like passwords)"