/**
 * @name Use of a broken or weak cryptographic hashing algorithm on sensitive data
 * @description Identifies instances where sensitive data is processed using weak or broken cryptographic hashing algorithms,
 *              which could lead to security vulnerabilities like hash collisions or preimage attacks.
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

// Import necessary Python analysis libraries
import python
// Import module for analyzing weak cryptographic hashing on sensitive data
import semmle.python.security.dataflow.WeakSensitiveDataHashingQuery
// Import data flow analysis framework
import semmle.python.dataflow.new.DataFlow
// Import taint tracking framework
import semmle.python.dataflow.new.TaintTracking
// Import path graph visualization for data flow
import WeakSensitiveDataHashingFlow::PathGraph

from
  // Define path nodes representing data flow source and sink
  WeakSensitiveDataHashingFlow::PathNode sourceNode, WeakSensitiveDataHashingFlow::PathNode sinkNode,
  // Variables for warning message suffix, hash algorithm identifier, and data type
  string warningMessageSuffix, string algorithmName, string dataType
where
  // Check for either normal or computationally intensive hash function flow
  (
    normalHashFunctionFlowPath(sourceNode, sinkNode) and
    // Extract algorithm name and data type for normal hash function
    algorithmName = sinkNode.getNode().(NormalHashFunction::Sink).getAlgorithmName() and
    dataType = sourceNode.getNode().(NormalHashFunction::Source).getClassification() and
    // Set default warning message suffix
    warningMessageSuffix = "."
  )
  or
  (
    computationallyExpensiveHashFunctionFlowPath(sourceNode, sinkNode) and
    // Extract algorithm name and data type for computationally expensive hash function
    algorithmName = sinkNode.getNode().(ComputationallyExpensiveHashFunction::Sink).getAlgorithmName() and
    dataType = sourceNode.getNode().(ComputationallyExpensiveHashFunction::Source).getClassification() and
    // Determine warning message suffix based on computational intensity
    (
      // Case when hash function is computationally expensive
      sinkNode.getNode().(ComputationallyExpensiveHashFunction::Sink).isComputationallyExpensive() and
      warningMessageSuffix = "."
      or
      // Case when hash function is not computationally expensive
      not sinkNode.getNode().(ComputationallyExpensiveHashFunction::Sink).isComputationallyExpensive() and
      warningMessageSuffix = " for " + dataType + " hashing, since it is not a computationally expensive hash function."
    )
  )
select 
  // Output results with sink node, source node, sink node (for path), warning message, and source node (for message)
  sinkNode.getNode(), sourceNode, sinkNode,
  "$@ is used in a hashing algorithm (" + algorithmName + ") that is insecure" + warningMessageSuffix,
  sourceNode.getNode(), "Sensitive data (" + dataType + ")"