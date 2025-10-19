/**
 * @name Use of a broken or weak cryptographic hashing algorithm on sensitive data
 * @description Detects when sensitive data is processed using weak or broken cryptographic hashing algorithms,
 *              potentially leading to security vulnerabilities such as hash collisions or preimage attacks.
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
  // Define path nodes representing data flow origin and destination
  WeakSensitiveDataHashingFlow::PathNode originNode, WeakSensitiveDataHashingFlow::PathNode destinationNode,
  // Variables for message suffix, hash algorithm identifier, and data classification
  string warningSuffix, string hashAlgorithm, string dataClassification
where
  // Process standard hash function flow scenario
  (
    normalHashFunctionFlowPath(originNode, destinationNode) and
    // Extract hash algorithm name from destination node
    hashAlgorithm = destinationNode.getNode().(NormalHashFunction::Sink).getAlgorithmName() and
    // Extract data classification from origin node
    dataClassification = originNode.getNode().(NormalHashFunction::Source).getClassification() and
    // Set default warning suffix
    warningSuffix = "."
  )
  or
  // Process computationally intensive hash function flow scenario
  (
    computationallyExpensiveHashFunctionFlowPath(originNode, destinationNode) and
    // Extract hash algorithm name from destination node
    hashAlgorithm = destinationNode.getNode().(ComputationallyExpensiveHashFunction::Sink).getAlgorithmName() and
    // Extract data classification from origin node
    dataClassification = originNode.getNode().(ComputationallyExpensiveHashFunction::Source).getClassification() and
    // Determine warning suffix based on computational intensity
    (
      // Case when hash function is computationally expensive
      destinationNode.getNode().(ComputationallyExpensiveHashFunction::Sink).isComputationallyExpensive() and
      warningSuffix = "."
      or
      // Case when hash function is not computationally expensive
      not destinationNode.getNode().(ComputationallyExpensiveHashFunction::Sink).isComputationallyExpensive() and
      warningSuffix = " for " + dataClassification + " hashing, since it is not a computationally expensive hash function."
    )
  )
select 
  // Output results with destination node, origin node, destination node (for path), warning message, and origin node (for message)
  destinationNode.getNode(), originNode, destinationNode,
  "$@ is used in a hashing algorithm (" + hashAlgorithm + ") that is insecure" + warningSuffix,
  originNode.getNode(), "Sensitive data (" + dataClassification + ")"