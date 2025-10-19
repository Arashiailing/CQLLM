/**
 * @name Timing attack against secret
 * @description Use of a non-constant-time verification routine to check the value of an secret,
 *              possibly allowing a timing attack to retrieve sensitive information.
 * @kind path-problem
 * @problem.severity error
 * @precision low
 * @id py/possible-timing-attack-sensitive-info
 * @tags security
 *       external/cwe/cwe-208
 *       experimental
 */

// Import Python language library
import python
// Import data flow analysis module
import semmle.python.dataflow.new.DataFlow
// Import taint tracking module
import semmle.python.dataflow.new.TaintTracking
// Import TimingAttack submodule from experimental security analysis module
import experimental.semmle.python.security.TimingAttack

/**
 * Configuration for taint tracking: flow from client secret source to non-constant-time comparison sink.
 * 配置污点跟踪：从客户端秘密源到非恒定时间比较汇的流动路径。
 */
private module TimingAttackConfig implements DataFlow::ConfigSig {
  // Define source: nodes that are secret sources
  predicate isSource(DataFlow::Node source) { source instanceof SecretSource }

  // Define sink: nodes that are non-constant-time comparison sinks
  predicate isSink(DataFlow::Node sink) { sink instanceof NonConstantTimeComparisonSink }

  // Incremental mode configuration: use any mode (no restrictions)
  predicate observeDiffInformedIncrementalMode() { any() }
}

// Define global taint tracking flow for detecting potential timing attack paths
module TimingAttackFlow = TaintTracking::Global<TimingAttackConfig>;

// Import path graph for path-problem analysis
import TimingAttackFlow::PathGraph

// Query to find flow paths from source to sink
from
  TimingAttackFlow::PathNode src,   // Source node representing secret origin
  TimingAttackFlow::PathNode snk    // Sink node representing vulnerable comparison
where 
  TimingAttackFlow::flowPath(src, snk)  // Condition: existing flow path from source to sink
select 
  snk.getNode(),                      // Sink node for result display
  src,                                // Source node in path
  snk,                                // Sink node in path
  "Timing attack against $@ validation.", // Alert message
  src.getNode(),                      // Message parameter reference
  "client-supplied token"             // Parameter description