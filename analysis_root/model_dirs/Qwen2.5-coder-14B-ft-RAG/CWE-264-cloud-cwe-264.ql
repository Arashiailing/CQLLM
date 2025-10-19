/**
 * @name CWE CATEGORY: Permissions, Privileges, and Access Controls
 * @description nan
 * @kind problem
 * @problem.severity recommendation
 * @security-severity 7.5
 * @precision medium
 * @id py/cloud-cwe-264
 * @tags security
 *       external/cwe/cwe-264
 */

import python
import semmle.python.dataflow.new.DataFlow
import CleartextStorageQuery
import semmle.python.filters.Tests

from CleartextStorage::PathNode source, CleartextStorage::PathNode sink, string type
where
  (
    source = sink.getAnOrigin()
    and
    (
      type = "storage"
      or
      type = "encryption"
    )
  )
  or
  (
    (
      type = "storage"
      and
      CleartextStorage::storagePath(source, sink)
    )
    or
    (
      type = "encryption"
      and
      CleartextStorage::cryptoPath(source, sink)
    )
  )
  and
  not source.getNode().getLocation().getFile() instanceof Test
select sink.getNode(),
  source,
  sink,
  "$@ is stored in cleartext in $@.", // 描述信息：存储在明文中的$@
  source.getNode(),
  "data",
  source,
  type,
  "this " + type