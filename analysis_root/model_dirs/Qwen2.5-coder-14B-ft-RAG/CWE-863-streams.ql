/**
 * @name CWE-863: Incorrect Authorization
 * @description The product performs an authorization check when an actor attempts to access a resource or perform an action, but it does not correctly perform the check.
 * @kind path-problem
 * @id py/streams
 * @problem.severity error
 * @precision medium
 * @tags security
 *       external/cwe/cwe-863
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.TaintTracking
import semmle.python.Concepts

// 定义流分析配置，追踪从HTTP请求体到授权检查的数据流
private module StreamSecurityFlow extends TaintTracking::Global<StreamSecurityFlow> {
  predicate isSource(DataFlow::Node src) { 
    src instanceof Http::Client::RequestBody 
  }
  predicate isSink(DataFlow::Node sink) { 
    sink.(Sink).flowsTo(unbox(any(InScope i)), _) 
  }
}

// 导入自定义路径图模块，用于表示数据流路径
import StreamSecurityFlow::PathGraph

// 查询语句：查找所有从源节点到汇点节点的路径，并选择汇点节点、源节点和汇点节点的信息，以及问题描述信息
from StreamSecurityFlow::PathNode source, StreamSecurityFlow::PathNode sink
where StreamSecurityFlow::flowPath(source, sink)
select sink.getNode(), source, sink,
  "This authorization test depends on a $@.", source.getNode(), "user-provided value"