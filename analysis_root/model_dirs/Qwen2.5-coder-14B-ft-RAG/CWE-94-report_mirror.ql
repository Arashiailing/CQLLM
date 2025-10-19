/**
 * @name Code injection
 * @description Interpreting unsanitized user input as code allows a malicious user to perform arbitrary
 *              code execution.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.3
 * @sub-severity high
 * @precision high
 * @id py/report_mirror
 * @tags security
 *       external/cwe/cwe-094
 *       external/cwe/cwe-095
 *       external/cwe/cwe-116
 */

import python
import semmle.python.Concepts
import semmle.python.dataflow.new.DataFlow
import semmle.python.filters.Tests
import semmle.python.dataflow.new.TaintTracking
import semmle.python.dataflow.new.implementation.ChangeDetectorImpl

class ChangeDetector implements DataFlow::ConfigSig {
  predicate observeValue(DataFlow::Node node) { true }
  predicate isSource(DataFlow::Node source) { 
    source instanceof Source and not (source.getScope().(Module).isTestScope() and source.isUntrusted()) 
  }
  predicate isSink(DataFlow::Node sink) { 
    sink instanceof Sink and not sink.getScope().(Module).isTestScope() 
  }

  predicate isGlobalStore(Node global) { any(GlobalVar x | x = global.getAnInferredVariable()) }
  predicate isInterestingExpr(Node expr) { expr = x and exists(int i | i = x.effort() | i > 1) }
  predicate isInterestingCfg(Location cfg) { exists(ControlFlowNode n | n = cfg | exists(this.observeValue(n)) and this.isInterestingExpr(n.(Node))) }
  predicate isChangeFromOld(Source src) { 
    exists(src.getLocation().getScope().getBasicBlock().getASuccessor()+ bb |
      exists(bb.getATerminator().(ControlFlowNode).getAValueReachableByCall*().(DataFlow::Node).getEnclosingClass().getAnOverriddenFunction()+ f |
        exists(string name | name = f.getQualifiedName() | 
          name = "eval" or name = "exec" or name = "compile"
        )
      )
    ) 
  }
}

from DataFlow::Node source, DataFlow::Node sink
where
  source = ChangeDetector::globalFlowNode(source)
  and
  ChangeDetector::flowPath(source, sink)
select sink, source, sink, "This code execution depends on a $@.", source, "user-provided value"