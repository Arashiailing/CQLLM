/**
 * @name Use of a broken or weak cryptographic hashing algorithm on sensitive data
 * @description Identifies instances where sensitive data is processed using weak or broken cryptographic hashing algorithms,
 *              which can lead to security vulnerabilities such as hash collisions or preimage attacks.
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
// Import the query module for analyzing weak cryptographic hashing on sensitive data
import semmle.python.security.dataflow.WeakSensitiveDataHashingQuery
// Import the data flow analysis framework
import semmle.python.dataflow.new.DataFlow
// Import the taint tracking framework
import semmle.python.dataflow.new.TaintTracking
// Import the path graph class for visualizing data flow paths
import WeakSensitiveDataHashingFlow::PathGraph

from
  // Define path nodes for data origin and target of data flow
  WeakSensitiveDataHashingFlow::PathNode dataOriginNode, WeakSensitiveDataHashingFlow::PathNode dataTargetNode,
  // Define variables for warning suffix, hash algorithm name, and data classification
  string warningSuffix, string hashAlgorithmName, string dataClassification
where
  // Logic for standard hash function flow path
  (
    normalHashFunctionFlowPath(dataOriginNode, dataTargetNode) and
    // Extract hash algorithm name from the target node
    hashAlgorithmName = dataTargetNode.getNode().(NormalHashFunction::Sink).getAlgorithmName() and
    // Extract data classification from the origin node
    dataClassification = dataOriginNode.getNode().(NormalHashFunction::Source).getClassification() and
    // Set default warning suffix
    warningSuffix = "."
  )
  or
  // Logic for computationally intensive hash function flow path
  (
    computationallyExpensiveHashFunctionFlowPath(dataOriginNode, dataTargetNode) and
    // Extract hash algorithm name from the target node
    hashAlgorithmName = dataTargetNode.getNode().(ComputationallyExpensiveHashFunction::Sink).getAlgorithmName() and
    // Extract data classification from the origin node
    dataClassification = dataOriginNode.getNode().(ComputationallyExpensiveHashFunction::Source).getClassification() and
    // Determine warning suffix based on computational expense
    (
      // If computationally expensive, use default suffix
      dataTargetNode.getNode().(ComputationallyExpensiveHashFunction::Sink).isComputationallyExpensive() and
      warningSuffix = "."
      or
      // If not computationally expensive, provide specific warning
      not dataTargetNode.getNode().(ComputationallyExpensiveHashFunction::Sink).isComputationallyExpensive() and
      warningSuffix = " for " + dataClassification + " hashing, since it is not a computationally expensive hash function."
    )
  )
select 
  // Output the target node, origin node, target node (for path), warning message, and origin node (for message)
  dataTargetNode.getNode(), dataOriginNode, dataTargetNode,
  "$@ is used in a hashing algorithm (" + hashAlgorithmName + ") that is insecure" + warningSuffix,
  dataOriginNode.getNode(), "Sensitive data (" + dataClassification + ")"