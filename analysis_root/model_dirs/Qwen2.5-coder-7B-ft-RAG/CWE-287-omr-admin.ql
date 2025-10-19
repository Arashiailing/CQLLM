/**
 * @name Cleartext storage of sensitive information
 * @description Storing sensitive information in cleartext exposes it to interception and tampering.
 * @kind problem
 * @problem.severity warning
 * @security-severity 5.0
 * @precision medium
 * @id py/cleartext-storage-query
 * @tags security
 *       external/cwe/cwe-312
 */

// Import Python language support library
import python

// Import custom analysis module for detecting cleartext storage vulnerabilities
import semmle.python.security.dataflow.CleartextStorageQuery

// Define query predicate to identify cleartext storage issues
query predicate cleartext_storage_issue(DataFlow::Node dataFlowNode) {
  // Condition: Node represents a cleartext storage sink
  dataFlowNode instanceof CleartextStorageSink
}

// Select cleartext storage nodes along with location context
from CleartextStorageFlow::PathNode taintedSource, CleartextStorageFlow::PathNode sinkNode
where
  // Verify existence of flow path from source to sink
  CleartextStorageFlow::flowPath(taintedSource, sinkNode) and
  // Ensure source node corresponds to actual data flow node
  taintedSource.getNode() = cleartext_storage_issue(sinkNode)
select sinkNode.getNode(),
  // Generate descriptive message indicating potential cleartext storage issue
  taintedSource,
  sinkNode,
  "Storing a $@ in cleartext.",
  taintedSource.getNode(),
  "confidential value"