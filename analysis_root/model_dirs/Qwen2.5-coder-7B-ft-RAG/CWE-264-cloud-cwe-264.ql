/**
 * @name CWE-264: Cleartext storage
 * @description Storing sensitive data in cleartext files exposes it to unauthorized access.
 * @kind problem
 * @problem.severity warning
 * @security-severity 9.1
 * @precision high
 * @id py/cloud-cwe-264
 * @tags security
 *       external/cwe/cwe-264
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.ApiGraphs
import CleartextStorageFlow::PathGraph

from CleartextStorageFlow::PathNode source, CleartextStorageFlow::PathNode sink
where CleartextStorageFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Data flows into this file through $@.", source,
  "user-controlled input"