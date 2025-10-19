/**
 * @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * @description nan
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision medium
 * @id py/cleartext-storage
 * @tags security
 *       external/cwe/cwe-312
 *       external/cwe/cwe-315
 */

import python
import semmle.python.security.dataflow.CleartextStorageQuery
import CleartextStorageFlow::PathGraph

from
  CleartextStorageFlow::PathNode source,
  CleartextStorageFlow::PathNode sink,
  string classification
where
  CleartextStorageFlow::flowPath(source, sink) and
  classification = source.getNode().getClassification()
select sink.getNode(),
  source, 
  sink,
  "This expression stores sensitive data in clear text (" + classification + ")."