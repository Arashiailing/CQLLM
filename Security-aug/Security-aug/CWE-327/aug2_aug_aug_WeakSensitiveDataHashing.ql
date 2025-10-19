/**
 * @name Use of a broken or weak cryptographic hashing algorithm on sensitive data
 * @description Detects when sensitive information is processed using weak or broken cryptographic hashing algorithms,
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

// Import essential Python analysis libraries
import python
// Import specialized module for weak cryptographic hashing analysis on sensitive data
import semmle.python.security.dataflow.WeakSensitiveDataHashingQuery
// Import data flow and taint tracking frameworks
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.TaintTracking
// Import path graph visualization component
import WeakSensitiveDataHashingFlow::PathGraph

from
  // Define path nodes representing the origin of sensitive data and the hashing operation
  WeakSensitiveDataHashingFlow::PathNode dataOriginNode, WeakSensitiveDataHashingFlow::PathNode hashingOperationNode,
  // Variables for constructing the warning message and algorithm details
  string warningMessageSuffix, string hashAlgorithmName, string dataSensitivityClassification
where
  // Scenario 1: Data flows through a standard hash function
  (
    normalHashFunctionFlowPath(dataOriginNode, hashingOperationNode) and
    // Extract the algorithm name from the hashing operation
    hashAlgorithmName = hashingOperationNode.getNode().(NormalHashFunction::Sink).getAlgorithmName() and
    // Extract the data classification from the source
    dataSensitivityClassification = dataOriginNode.getNode().(NormalHashFunction::Source).getClassification() and
    // Use default message suffix for standard hash functions
    warningMessageSuffix = "."
  )
  or
  // Scenario 2: Data flows through a computationally intensive hash function
  (
    computationallyExpensiveHashFunctionFlowPath(dataOriginNode, hashingOperationNode) and
    // Extract the algorithm name from the hashing operation
    hashAlgorithmName = hashingOperationNode.getNode().(ComputationallyExpensiveHashFunction::Sink).getAlgorithmName() and
    // Extract the data classification from the source
    dataSensitivityClassification = dataOriginNode.getNode().(ComputationallyExpensiveHashFunction::Source).getClassification() and
    // Determine appropriate message suffix based on computational properties
    (
      // If the hash function is computationally expensive, use default suffix
      hashingOperationNode.getNode().(ComputationallyExpensiveHashFunction::Sink).isComputationallyExpensive() and
      warningMessageSuffix = "."
      or
      // If not computationally expensive, provide specific warning context
      not hashingOperationNode.getNode().(ComputationallyExpensiveHashFunction::Sink).isComputationallyExpensive() and
      warningMessageSuffix = " for " + dataSensitivityClassification + " hashing, since it is not a computationally expensive hash function."
    )
  )
select 
  // Output the vulnerable hashing operation, data flow path, and warning message
  hashingOperationNode.getNode(), dataOriginNode, hashingOperationNode,
  "$@ is used in a hashing algorithm (" + hashAlgorithmName + ") that is insecure" + warningMessageSuffix,
  dataOriginNode.getNode(), "Sensitive data (" + dataSensitivityClassification + ")"