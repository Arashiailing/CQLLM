/**
 * @name Use of a broken or weak cryptographic hashing algorithm on sensitive data
 * @description Identifies sensitive information processed using weak/broken cryptographic hashing algorithms,
 *              potentially enabling security vulnerabilities like hash collisions or preimage attacks.
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

// Core Python analysis modules
import python
// Specialized library for detecting weak cryptographic hashing of sensitive data
import semmle.python.security.dataflow.WeakSensitiveDataHashingQuery
// Data flow and taint tracking frameworks
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.TaintTracking
// Path graph visualization component
import WeakSensitiveDataHashingFlow::PathGraph

from
  // Path nodes representing sensitive data source and vulnerable hashing operation
  WeakSensitiveDataHashingFlow::PathNode sourceNode, WeakSensitiveDataHashingFlow::PathNode sinkNode,
  // Variables for warning message components
  string messageSuffix, string algorithmName, string sensitivityType
where
  // Case 1: Standard hash function vulnerability
  (
    normalHashFunctionFlowPath(sourceNode, sinkNode) and
    // Extract algorithm identifier from hashing operation
    algorithmName = sinkNode.getNode().(NormalHashFunction::Sink).getAlgorithmName() and
    // Extract sensitivity classification from data source
    sensitivityType = sourceNode.getNode().(NormalHashFunction::Source).getClassification() and
    // Default suffix for standard hash functions
    messageSuffix = "."
  )
  or
  // Case 2: Computationally intensive hash function vulnerability
  (
    computationallyExpensiveHashFunctionFlowPath(sourceNode, sinkNode) and
    // Extract algorithm identifier from hashing operation
    algorithmName = sinkNode.getNode().(ComputationallyExpensiveHashFunction::Sink).getAlgorithmName() and
    // Extract sensitivity classification from data source
    sensitivityType = sourceNode.getNode().(ComputationallyExpensiveHashFunction::Source).getClassification() and
    // Determine context-specific warning suffix
    (
      // Computationally expensive functions use default suffix
      sinkNode.getNode().(ComputationallyExpensiveHashFunction::Sink).isComputationallyExpensive() and
      messageSuffix = "."
      or
      // Non-computationally expensive functions get context-specific suffix
      not sinkNode.getNode().(ComputationallyExpensiveHashFunction::Sink).isComputationallyExpensive() and
      messageSuffix = " for " + sensitivityType + " hashing, since it is not a computationally expensive hash function."
    )
  )
select 
  // Vulnerable hashing operation, data flow path, and warning message
  sinkNode.getNode(), sourceNode, sinkNode,
  "$@ is processed using a weak hashing algorithm (" + algorithmName + ")" + messageSuffix,
  sourceNode.getNode(), "Sensitive data (" + sensitivityType + ")"