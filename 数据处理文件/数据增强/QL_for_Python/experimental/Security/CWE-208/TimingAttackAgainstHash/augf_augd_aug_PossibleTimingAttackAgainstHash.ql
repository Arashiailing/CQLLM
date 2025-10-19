/**
 * @name Hash Verification Timing Vulnerability
 * @description Detects potential timing attacks during hash verification.
 *              Non-constant-time comparisons allow attackers to forge valid hashes
 *              through response time analysis, bypassing authentication.
 * @kind path-problem
 * @problem.severity error
 * @precision low
 * @id py/possible-timing-attack-against-hash
 * @tags security
 *       external/cwe/cwe-208
 *       experimental
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.TaintTracking
import experimental.semmle.python.security.TimingAttack

// Configuration for hash timing attack detection
private module HashTimingConfig implements DataFlow::ConfigSig {
  // Source: Cryptographic hash generation operations
  predicate isSource(DataFlow::Node hashOperation) { 
    hashOperation instanceof ProduceCryptoCall 
  }

  // Sink: Non-constant-time comparison operations
  predicate isSink(DataFlow::Node vulnerableComparison) { 
    vulnerableComparison instanceof NonConstantTimeComparisonSink 
  }
}

// Initialize taint tracking with timing attack configuration
module HashTimingFlow = TaintTracking::Global<HashTimingConfig>;
import HashTimingFlow::PathGraph

// Main detection logic for timing attack vulnerability paths
from
  HashTimingFlow::PathNode hashSource,      // Source node for cryptographic operations
  HashTimingFlow::PathNode timingSink       // Sink node for vulnerable comparisons
where 
  HashTimingFlow::flowPath(hashSource, timingSink)
select 
  timingSink.getNode(), 
  hashSource, 
  timingSink, 
  "Timing attack vulnerability in $@ verification",
  hashSource.getNode().(ProduceCryptoCall).getResultType(), 
  "message hash"