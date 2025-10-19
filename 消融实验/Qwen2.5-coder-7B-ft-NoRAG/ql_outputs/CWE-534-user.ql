/**
 * @name CWE-534: DEPRECATED: Information Exposure Through Debug Log Files
 * @id py/cleartext-storage-query
 */

import python
import semmle.python.security.dataflow.CleartextStorageQuery

from CleartextStorageFlow::PathNode source, CleartextStorageFlow::PathNode sink
where CleartextStorageFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This cleartext storage depends on a $@.", source.getNode(), "user-provided value"