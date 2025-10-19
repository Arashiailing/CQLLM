/**
 * @name JavaScript code execution via Js2Py
 * @description User-controlled input passed to Js2Py evaluation functions can result in remote code execution
 * @problem.severity error
 * @security-severity 9.3
 * @precision high
 * @kind path-problem
 * @id py/js2py-rce
 * @tags security
 *       experimental
 *       external/cwe/cwe-94
 */

import python
import semmle.python.ApiGraphs
import semmle.python.dataflow.new.TaintTracking
import semmle.python.dataflow.new.RemoteFlowSources
import semmle.python.Concepts

// Configuration module for Js2Py-related data flow analysis
module Js2PyDataFlowConfig implements DataFlow::ConfigSig {
  // Identify data flow sources: nodes representing active threat model sources
  predicate isSource(DataFlow::Node dataNode) { dataNode instanceof ActiveThreatModelSource }

  // Identify data flow sinks: calls to Js2Py evaluation functions with tainted arguments
  predicate isSink(DataFlow::Node dataNode) {
    API::moduleImport("js2py")
        .getMember(["eval_js", "eval_js6", "EvalJs"])
        .getACall()
        .getArg(_) = dataNode
  }

  // Enable differential analysis for incremental mode (always active)
  predicate observeDiffInformedIncrementalMode() { any() }
}

// Global taint tracking analysis using Js2Py configuration
module Js2PyTaintFlow = TaintTracking::Global<Js2PyDataFlowConfig>;

import Js2PyTaintFlow::PathGraph

// Select paths where tainted data flows to Js2Py evaluation functions
// without prior mitigation via disable_pyimport
from Js2PyTaintFlow::PathNode source, Js2PyTaintFlow::PathNode sink
where
  Js2PyTaintFlow::flowPath(source, sink) and
  not exists(API::moduleImport("js2py").getMember("disable_pyimport").getACall())
select sink, source, sink, "This input to Js2Py depends on a $@.", source.getNode(),
  "user-provided value"