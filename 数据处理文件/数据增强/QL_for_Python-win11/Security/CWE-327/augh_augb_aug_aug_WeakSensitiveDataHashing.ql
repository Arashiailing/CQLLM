/**
 * @name Use of a broken or weak cryptographic hashing algorithm on sensitive data
 * @description Identifies instances where sensitive data undergoes processing using weak or broken cryptographic hashing algorithms,
 *              which may introduce security vulnerabilities including hash collisions or preimage attacks.
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

// Import required Python analysis libraries
import python
// Import specialized module for analyzing weak cryptographic hashing on sensitive data
import semmle.python.security.dataflow.WeakSensitiveDataHashingQuery
// Import the data flow analysis framework
import semmle.python.dataflow.new.DataFlow
// Import taint tracking framework
import semmle.python.dataflow.new.TaintTracking
// Import path graph visualization for data flow
import WeakSensitiveDataHashingFlow::PathGraph

from
  // Define path nodes representing data flow source and target
  WeakSensitiveDataHashingFlow::PathNode sourceNode, WeakSensitiveDataHashingFlow::PathNode targetNode,
  // Variables for message suffix, hash algorithm identifier, and data classification
  string messageSuffix, string algoName, string dataCategory
where
  // Handle standard hash function flow scenario
  (
    normalHashFunctionFlowPath(sourceNode, targetNode) and
    // Extract hash algorithm name from target node
    algoName = targetNode.getNode().(NormalHashFunction::Sink).getAlgorithmName() and
    // Extract data classification from source node
    dataCategory = sourceNode.getNode().(NormalHashFunction::Source).getClassification() and
    // Set default warning suffix
    messageSuffix = "."
  )
  or
  // Handle computationally intensive hash function flow scenario
  (
    computationallyExpensiveHashFunctionFlowPath(sourceNode, targetNode) and
    // Extract hash algorithm name from target node
    algoName = targetNode.getNode().(ComputationallyExpensiveHashFunction::Sink).getAlgorithmName() and
    // Extract data classification from source node
    dataCategory = sourceNode.getNode().(ComputationallyExpensiveHashFunction::Source).getClassification() and
    // Determine warning suffix based on computational intensity
    (
      // Case when hash function is computationally expensive
      targetNode.getNode().(ComputationallyExpensiveHashFunction::Sink).isComputationallyExpensive() and
      messageSuffix = "."
      or
      // Case when hash function is not computationally expensive
      not targetNode.getNode().(ComputationallyExpensiveHashFunction::Sink).isComputationallyExpensive() and
      messageSuffix = " for " + dataCategory + " hashing, since it is not a computationally expensive hash function."
    )
  )
select 
  // Output results with target node, source node, target node (for path), warning message, and source node (for message)
  targetNode.getNode(), sourceNode, targetNode,
  "$@ is processed using an insecure hashing algorithm (" + algoName + ")" + messageSuffix,
  sourceNode.getNode(), "Sensitive data (" + dataCategory + ")"