/**
 * @name CWE-522: Insufficiently Protected Credentials
 * @description nan
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.8
 * @sub-severity low
 * @precision medium
 * @id py/base-cwe-522
 * @tags security
 */

import python
import semmle.python.security.dataflow.CleartextStorageQuery
import CleartextStorageFlow::PathGraph

from CleartextStorageFlow::PathNode source, CleartextStorageFlow::PathNode sink
where CleartextStorageFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This expression stores credentials in cleartext."