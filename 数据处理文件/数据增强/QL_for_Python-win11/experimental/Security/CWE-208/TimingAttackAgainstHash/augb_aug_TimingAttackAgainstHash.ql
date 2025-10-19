/**
 * @name Timing Attack Vulnerability in Hash Verification
 * @description Detects potential timing attacks when verifying cryptographic hashes.
 *              Non-constant-time comparisons enable attackers to forge valid hashes
 *              through timing side-channels if they can submit verification requests.
 *              Successful exploitation may result in authentication bypass.
 * @kind path-problem
 * @problem.severity error
 * @precision low
 * @id py/timing-attack-against-hash
 * @tags security
 *       external/cwe/cwe-208
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.TaintTracking
import experimental.semmle.python.security.TimingAttack

/**
 * Configuration module for tracking data flow from cryptographic operations
 * to equality comparisons that are vulnerable to timing attacks.
 */
private module CryptoTimingAnalysisConfig implements DataFlow::ConfigSig {
  // Define cryptographic operation outputs as data flow sources
  predicate isSource(DataFlow::Node hashOutputSource) { 
    hashOutputSource instanceof ProduceCryptoCall 
  }

  // Define non-constant-time comparisons as data flow sinks
  predicate isSink(DataFlow::Node timingVulnerableSink) { 
    timingVulnerableSink instanceof NonConstantTimeComparisonSink 
  }
}

// Global taint tracking module using the configuration
module CryptoTimingAnalysisFlow = TaintTracking::Global<CryptoTimingAnalysisConfig>;

import CryptoTimingAnalysisFlow::PathGraph

// Query to identify timing attack paths involving user input
from CryptoTimingAnalysisFlow::PathNode sourceNode, CryptoTimingAnalysisFlow::PathNode sinkNode
where
  // Data flow path exists from cryptographic operation to comparison
  CryptoTimingAnalysisFlow::flowPath(sourceNode, sinkNode) and
  // Comparison operation involves user-controllable input
  sinkNode.getNode().(NonConstantTimeComparisonSink).includesUserInput()
select 
  sinkNode.getNode(), 
  sourceNode, 
  sinkNode, 
  "Timing attack against $@ validation.", 
  sourceNode.getNode().(ProduceCryptoCall).getResultType(), 
  "message"