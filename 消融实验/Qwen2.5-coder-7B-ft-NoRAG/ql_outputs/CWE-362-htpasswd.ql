/**
 * @name CWE-362: CleartextStorageQuery
 * @description Storing sensitive information in cleartext can lead to exposure of sensitive data.
 * @kind problem
 * @id py/cleartext-storage-query
 * @problem.severity error
 * @security-severity 8.0
 * @precision high
 * @tags security
 */

import python
import semmle.python.security.dataflow.CleartextStorageQuery
import CleartextStorageFlow::PathGraph

from CleartextStorageFlow::PathNode source, CleartextStorageFlow::PathNode sink
where CleartextStorageFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Sensitive information stored in cleartext at $@.", source.getNode()