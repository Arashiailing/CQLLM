/**
 * @name Sensitive data processed with weak cryptographic hash function
 * @description Detects when sensitive data is hashed using broken or weak cryptographic algorithms,
 *              which can lead to security vulnerabilities.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 7.5
 * @precision high
 * @id py/weak-sensitive-data-hashing
 * @tags security
 *       external/cwe/cwe-327
 *       external/cwe/cwe-328
 *       external/cwe/cwe-916
 */

// Import Python language support for analysis
import python
// Import specialized module for analyzing weak sensitive data hashing patterns
import semmle.python.security.dataflow.WeakSensitiveDataHashingQuery
// Import advanced data flow analysis framework
import semmle.python.dataflow.new.DataFlow
// Import taint tracking capabilities for security analysis
import semmle.python.dataflow.new.TaintTracking
// Import path graph utilities for visualizing data flow paths
import WeakSensitiveDataHashingFlow::PathGraph

from
  // Define source and sink nodes for path analysis
  WeakSensitiveDataHashingFlow::PathNode sourceNode, WeakSensitiveDataHashingFlow::PathNode sinkNode,
  // Define variables for constructing the result message
  string messageSuffix, string algorithmName, string sensitiveDataType
where
  // Case 1: Standard hash function with weak algorithm
  (
    normalHashFunctionFlowPath(sourceNode, sinkNode) and
    algorithmName = sinkNode.getNode().(NormalHashFunction::Sink).getAlgorithmName() and
    sensitiveDataType = sourceNode.getNode().(NormalHashFunction::Source).getClassification() and
    messageSuffix = "."
  )
  or
  // Case 2: Hash function that should be computationally expensive
  (
    computationallyExpensiveHashFunctionFlowPath(sourceNode, sinkNode) and
    algorithmName = sinkNode.getNode().(ComputationallyExpensiveHashFunction::Sink).getAlgorithmName() and
    sensitiveDataType = sourceNode.getNode().(ComputationallyExpensiveHashFunction::Source).getClassification() and
    (
      // Subcase 2.1: Function meets computational expense requirements
      (
        sinkNode.getNode().(ComputationallyExpensiveHashFunction::Sink).isComputationallyExpensive() and
        messageSuffix = "."
      )
      or
      // Subcase 2.2: Function fails to meet computational expense requirements
      (
        not sinkNode.getNode().(ComputationallyExpensiveHashFunction::Sink).isComputationallyExpensive() and
        messageSuffix = " for " + sensitiveDataType + " hashing, since it is not a computationally expensive hash function."
      )
    )
  )
select 
  // Select the sink node, source node, sink node, warning message, and sensitive data type
  sinkNode.getNode(), sourceNode, sinkNode,
  "$@ is used in a hashing algorithm (" + algorithmName + ") that is insecure" + messageSuffix,
  sourceNode.getNode(), "Sensitive data (" + sensitiveDataType + ")"