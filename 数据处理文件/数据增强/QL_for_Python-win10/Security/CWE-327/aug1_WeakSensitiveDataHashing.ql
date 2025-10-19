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

// Import Python language support
import python
// Import specialized query module for weak sensitive data hashing analysis
import semmle.python.security.dataflow.WeakSensitiveDataHashingQuery
// Import data flow analysis framework
import semmle.python.dataflow.new.DataFlow
// Import taint tracking capabilities
import semmle.python.dataflow.new.TaintTracking
// Import path graph for visualization of data flows
import WeakSensitiveDataHashingFlow::PathGraph

from
  // Define origin and destination nodes for path analysis
  WeakSensitiveDataHashingFlow::PathNode origin, WeakSensitiveDataHashingFlow::PathNode destination,
  // Define variables for result message components
  string messageSuffix, string hashAlgorithm, string dataCategory
where
  // Case 1: Normal hash function flow path
  (
    normalHashFunctionFlowPath(origin, destination) and
    hashAlgorithm = destination.getNode().(NormalHashFunction::Sink).getAlgorithmName() and
    dataCategory = origin.getNode().(NormalHashFunction::Source).getClassification() and
    messageSuffix = "."
  )
  or
  // Case 2: Computationally expensive hash function flow path
  (
    computationallyExpensiveHashFunctionFlowPath(origin, destination) and
    hashAlgorithm = destination.getNode().(ComputationallyExpensiveHashFunction::Sink).getAlgorithmName() and
    dataCategory = origin.getNode().(ComputationallyExpensiveHashFunction::Source).getClassification() and
    (
      // Subcase 2.1: Function is computationally expensive
      (
        destination.getNode().(ComputationallyExpensiveHashFunction::Sink).isComputationallyExpensive() and
        messageSuffix = "."
      )
      or
      // Subcase 2.2: Function is not computationally expensive
      (
        not destination.getNode().(ComputationallyExpensiveHashFunction::Sink).isComputationallyExpensive() and
        messageSuffix = " for " + dataCategory + " hashing, since it is not a computationally expensive hash function."
      )
    )
  )
select 
  // Select the destination node, origin node, destination node, warning message, and data category
  destination.getNode(), origin, destination,
  "$@ is used in a hashing algorithm (" + hashAlgorithm + ") that is insecure" + messageSuffix,
  origin.getNode(), "Sensitive data (" + dataCategory + ")"