/**
 * @name JavaScript code execution.
 * @description Passing user supplied arguments to a Javascript to Python translation engine such as Js2Py can lead to remote code execution.
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

// 定义一个模块，用于配置数据流分析的源和汇点
module Js2PyFlowConfig implements DataFlow::ConfigSig {
  // 定义源节点的条件：节点是ActiveThreatModelSource类型
  predicate isSource(DataFlow::Node node) { node instanceof ActiveThreatModelSource }

  // 定义汇点节点的条件：调用了js2py模块中的eval_js、eval_js6或EvalJs方法，并且参数为当前节点
  predicate isSink(DataFlow::Node node) {
    API::moduleImport("js2py").getMember(["eval_js", "eval_js6", "EvalJs"]).getACall().getArg(_) =
      node
  }

  // 定义观察差异信息增量模式的条件：任何情况都满足
  predicate observeDiffInformedIncrementalMode() { any() }
}

// 使用全局污点跟踪模块进行数据流分析，并应用上述配置
module Js2PyFlow = TaintTracking::Global<Js2PyFlowConfig>;

import Js2PyFlow::PathGraph

// 从数据流路径图中选择源节点和汇点节点，其中存在从源到汇的数据流路径，并且没有调用js2py模块中的disable_pyimport方法
from Js2PyFlow::PathNode source, Js2PyFlow::PathNode sink
where
  Js2PyFlow::flowPath(source, sink) and
  not exists(API::moduleImport("js2py").getMember("disable_pyimport").getACall())
select sink, source, sink, "This input to Js2Py depends on a $@.", source.getNode(),
  "user-provided value"
