/**
 * @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * @description Storing sensitive information in cleartext exposes it to unauthorized actors.
 * @kind problem
 * @problem.severity warning
 * @security-severity 8.5
 * @precision high
 * @id py/exposure-of-sensitive-information
 * @tags security
 */

import python
import semmle.python.security.dataflow.CleartextStorageQuery

predicate hasSensitiveInformation(CleartextStorageQuery::DataFlowNode node) {
  exists(CleartextStorageQuery::DataFlowNode source, CleartextStorageQuery::DataFlowNode sink |
    CleartextStorageQuery::flowPath(source, sink) and
    source.getNode().hasDescendant(node)
  )
}

from CleartextStorageQuery::DataFlowNode node
where hasSensitiveInformation(node)
select node, "Storing sensitive information in cleartext exposes it to unauthorized actors."