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
  // Define path nodes for source and sink of data flow
  WeakSensitiveDataHashingFlow::PathNode dataSrc, WeakSensitiveDataHashingFlow::PathNode hashSink,
  // Define variables for message suffix, hash algorithm name, and data category
  string msgSuffix, string hashAlgorithm, string dataCategory
where
  // Case 1: Normal hash function flow path
  (
    normalHashFunctionFlowPath(dataSrc, hashSink) and
    // Extract hash algorithm name from the sink node
    hashAlgorithm = hashSink.getNode().(NormalHashFunction::Sink).getAlgorithmName() and
    // Extract data classification from the source node
    dataCategory = dataSrc.getNode().(NormalHashFunction::Source).getClassification() and
    // Set default message suffix
    msgSuffix = "."
  )
  or
  // Case 2: Computationally expensive hash function flow path
  (
    computationallyExpensiveHashFunctionFlowPath(dataSrc, hashSink) and
    // Extract hash algorithm name from the sink node
    hashAlgorithm = hashSink.getNode().(ComputationallyExpensiveHashFunction::Sink).getAlgorithmName() and
    // Extract data classification from the source node
    dataCategory = dataSrc.getNode().(ComputationallyExpensiveHashFunction::Source).getClassification() and
    // Determine message suffix based on whether the hash function is computationally expensive
    (
      // If the hash function is computationally expensive, use default suffix
      hashSink.getNode().(ComputationallyExpensiveHashFunction::Sink).isComputationallyExpensive() and
      msgSuffix = "."
      or
      // If not computationally expensive, provide specific warning message
      not hashSink.getNode().(ComputationallyExpensiveHashFunction::Sink).isComputationallyExpensive() and
      msgSuffix = " for " + dataCategory + " hashing, since it is not a computationally expensive hash function."
    )
  )
select 
  // Output the sink node, source node, sink node (for path), warning message, and source node (for message)
  hashSink.getNode(), dataSrc, hashSink,
  "$@ is used in a hashing algorithm (" + hashAlgorithm + ") that is insecure" + msgSuffix,
  dataSrc.getNode(), "Sensitive data (" + dataCategory + ")"