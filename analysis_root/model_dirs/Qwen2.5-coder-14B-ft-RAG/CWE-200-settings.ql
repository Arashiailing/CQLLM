/**
 * @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * @description Storing sensitive information in clear text can expose it to unauthorized actors.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @id py/clear-text-storage-sensitive-data
 * @tags security
 *       external/cwe/cwe-312
 *       external/cwe/cwe-315
 *       external/cwe/cwe-359
 */

import python
import semmle.python.dataflow.new.DataFlow
import CleartextStorageFlow::PathGraph
import semmle.python.security.dataflow.CleartextStorageQuery

from CleartextStorageFlow::PathNode source, CleartextStorageFlow::PathNode sink, string classification
where
  CleartextStorageFlow::flowPath(source, sink) and
  classification = source.getNode().(Source).getClassification()
select sink.getNode(), source, sink, "This expression stores $@ as clear text.", source.getNode(),
  "sensitive data (" + classification + ")"