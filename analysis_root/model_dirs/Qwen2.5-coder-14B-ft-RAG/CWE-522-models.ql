/**
 * @name CWE-522: Insufficiently Protected Credentials
 * @description nan
 * @kind problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision medium
 * @id py/models
 */

import python
import semmle.python.dataflow.new.DataFlow
import CleartextStorageQuery::Private
import semmle.python.dataflow.new.CFGPrivate

from CleartextStorageFlow::PathNode source, CleartextStorageFlow::PathNode sink
where CleartextStorageFlow::flowPath(source, sink)
select sink.getNode(),
  source,
  sink,
  "$@ is stored in a location where it may be accessed by unauthorized users.",
  source.getNode(), "credential"