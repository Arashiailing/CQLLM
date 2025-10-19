/**
 * @name CWE-255: Cleartext Storage of Sensitive Information
 * @kind problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision medium
 * @id py/cleartext-storage
 * @tags security
 *       external/cwe/cwe-255
 */

import python
import semmle.python.security.dataflow.CleartextStorageQuery
import CleartextStorageFlow::PathGraph

from CleartextStorageFlow::PathNode source, CleartextStorageFlow::PathNode sink
where CleartextStorageFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Sensitive information is stored in $@ without encryption.", source.getNode(),
  "unencrypted storage location"