/**
 * @name Weak hashing of sensitive data
 * @description Creating hashes of sensitive information using weak hashing functions may cause security vulnerabilities because they can be brute-forced.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 7.5
 * @precision high
 * @id py/weak-sensitive-data-hashing
 * @tags security
 *       external/cwe/cwe-310
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.TaintTracking
import semmle.python.dataflow.new.Configurations
import semmle.python.dataflow.new.UnreachableNodes

/*
 * This query detects unsafe hash function calls when processing sensitive data
 *
 * The query identifies calls to insecure hash functions that process classified information,
 * such as passwords or credit card details. These functions typically implement outdated
 * algorithms like MD5 or SHA1, which are no longer considered secure due to known collision attacks.
 *
 * A key characteristic of this vulnerability is that it focuses on the core purpose of hashing,
 * rather than incidental uses that could occur within larger algorithms. For instance, if
 * MD5 is used to calculate checksums for file validation, this query would flag those occurrences
 * since the primary intention of hashing in such cases is still to protect sensitive content.
 *
 * The analysis leverages taint tracking techniques to identify data flows originating from
 * sensitive data sources and propagating through the application until reaching hash function calls.
 * By doing so, we ensure that only instances where the entire hashing operation processes
 * sensitive data are reported, thus excluding scenarios involving mixed or partial data types.
 *
 * Potential Improvements:
 * - Expand the query to cover additional hashing contexts beyond password processing.
 * - Integrate this functionality into a comprehensive security module dedicated to hashing vulnerabilities.
 */
class UnsecureHashFunction extends Function {
  /**
   * Returns true if the current function represents an insecure hash algorithm.
   */
  private boolean isInsecureAlgorithm() {
    // Check if the function's name matches common weak hash algorithms
    this.(Name).getId() = "md5" or
    this.(Name).getId() = "sha1"
  }

  /**
   * Verifies whether the function's invocation constitutes a valid hashing operation.
   *
   * To qualify as a proper hash operation, the function must be called without arguments,
   * indicating that its default behavior is being utilized for hashing purposes.
   */
  private boolean isCalledProperly(Call call) {
    // Verify that the function is invoked with zero parameters
    call.getArg(0).getNode() instanceof PositionalParameter and
    call.getStarargs().getNode() instanceof PositionalParameter and
    call.getKwargs().getNode() instanceof PositionalParameter and
    forall(int i | i < call.getNumArgs() | i >= 0 | call.getArg(i).getNode() instanceof PositionalParameter)
  }

  predicate definesHashFunction() {
    this.isInsecureAlgorithm() and
    exists(Call call |
      call.getFunc() = this and
      call.getScope().getScope*() instanceof Module and
      this.isCalledProperly(call)
    )
  }
}

// Define the control flow framework based on CallCfg nodes
module ControlFlowFramework implements DataFlow::ControlFlow<CallCfgNode> {}

// Implement the taint tracking core logic
module TaintTrackingCore implements ConfiguredTaintTrackingCore<UnsecureHashFunction, ControlFlowFramework> {}

// Create the primary taint tracking module
module MainTrackingModule implements TaintTrackingCore with scope/1 = UnsecureHashFunction::scope/1 {}

// Instantiate the taint tracker for detecting data flow paths
module TaintTracker implements MainTrackingModule::TaintTrackingImpl<SourceNode, SinkNode> {}

// Instantiate the standard data flow analysis module
module StandardFlowAnalysis implements DataFlow::StandardLibraryFlow<TaintTracker> {}

// Generate taint tracking results by combining standard and source flow analyses
predicate taintedResult(SinkNode sink, SourceNode source) {
  StandardFlowAnalysis::flowPath(source, sink)
  or
  TaintTracker::flowPath(source, sink)
}

// Exclude unreachable source nodes from consideration
predicate excludeUnreachable(SourceNode source) {
  exists(UnreachableNode node | node = source.getNode())
}

// Exclude source nodes that are marked as unreachable
predicate filterOutUnreachableSources(SourceNode source) {
  not excludeUnreachable(source)
}

from SinkNode sink, SourceNode source
where
  taintedResult(sink, source) and
  filterOutUnreachableSources(source)
select sink.asExpr(), source, sink, "This call to a deprecated hash function depends on a $@.", source.getNode(),
  "user-controlled input"