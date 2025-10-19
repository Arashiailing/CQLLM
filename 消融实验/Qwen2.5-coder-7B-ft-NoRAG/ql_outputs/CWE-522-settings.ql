/**
 * @name CWE-522: Insufficiently Protected Credentials
 * @description Storing credentials in plain text is insecure.
 * @id py/settings
 * @tags security
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.security.dataflow.CleartextStorageQuery
import CleartextStorageFlow::PathGraph

from CleartextStorageFlow::PathNode source, CleartextStorageFlow::PathNode sink, string classification
where CleartextStorageFlow::flowPath(source, sink)
  and classification = source.getNode().(Source).getClassification()
  and classification!= "password"
select sink.getNode(), source, sink, "Credentials are stored in plain text."