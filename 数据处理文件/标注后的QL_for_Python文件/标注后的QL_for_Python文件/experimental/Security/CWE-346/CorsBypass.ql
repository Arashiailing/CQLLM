/**
 * @name 跨域资源共享（CORS）策略绕过
 * @description 使用弱比较器（如 'string.startswith'）检查用户提供的源标头可能导致 CORS 策略绕过。
 * @kind path-problem
 * @problem.severity warning
 * @id py/cors-bypass
 * @tags security
 *       externa/cwe/CWE-346
 */

import python
import semmle.python.ApiGraphs
import semmle.python.dataflow.new.TaintTracking
import semmle.python.Flow
import semmle.python.dataflow.new.RemoteFlowSources

/**
 * 如果控制流节点在当前上下文中可能有用，则返回 true。
 *
 * 理想情况下，我们应该对每个 `startswith` 调用和每个部分检查的远程流源进行警报。但是，由于这可能会导致大量误报，我们应用启发式方法来过滤一些调用。这个谓词提供此过滤的逻辑。
 */
private predicate maybeInteresting(ControlFlowNode c) {
  // 检查调用函数的变量名是否符合启发式规则。
  // 这通常发生在汇点。
  // 例如：`origin.startswith("bla")`
  heuristics(c.(CallNode).getFunction().(AttrNode).getObject().(NameNode).getId())
  or
  // 检查作为参数传递给函数的变量名是否符合启发式规则。这通常发生在汇点。
  // 例如：`bla.startswith(origin)`
  heuristics(c.(CallNode).getArg(0).(NameNode).getId())
  or
  // 检查值是否写入任何感兴趣的变量。这通常发生在源点。
  // 例如：`origin = request.headers.get('My-custom-header')`
  exists(Variable v | heuristics(v.getId()) | c.getASuccessor*().getNode() = v.getAStore())
}

// 定义一个类，用于表示字符串的 startswith 调用。
private class StringStartswithCall extends ControlFlowNode {
  StringStartswithCall() { this.(CallNode).getFunction().(AttrNode).getName() = "startswith" }
}

// 定义一个绑定集，用于存储符合启发式规则的字符串。
bindingset[s]
predicate heuristics(string s) { s.matches(["%origin%", "%cors%"]) }

/**
 * `cherrypy.request` 类的成员，作为 `RemoteFlowSource` 被获取。
 */
class CherryPyRequest extends RemoteFlowSource::Range {
  CherryPyRequest() {
    this =
      API::moduleImport("cherrypy")
          .getMember("request")
          .getMember([
              "charset", "content_type", "filename", "fp", "name", "params", "headers", "length",
            ])
          .asSource()
  }

  override string getSourceType() { result = "cherrypy.request" }
}

// 配置模块，用于定义数据流分析的配置。
module CorsBypassConfig implements DataFlow::ConfigSig {
  // 定义源节点的条件。
  predicate isSource(DataFlow::Node node) { node instanceof RemoteFlowSource }

  // 定义汇节点的条件。
  predicate isSink(DataFlow::Node node) {
    exists(StringStartswithCall s |
      node.asCfgNode() = s.(CallNode).getArg(0) or
      node.asCfgNode() = s.(CallNode).getFunction().(AttrNode).getObject()
    )
  }

  // 定义额外的流步骤条件。
  predicate isAdditionalFlowStep(DataFlow::Node node1, DataFlow::Node node2) {
    exists(API::CallNode c, API::Node n |
      n = API::moduleImport("cherrypy").getMember("request").getMember("headers") and
      c = n.getMember("get").getACall()
    |
      c.getReturn().asSource() = node2 and n.asSource() = node1
    )
  }

  // 观察差异信息增量模式。
  predicate observeDiffInformedIncrementalMode() { any() }
}

// 全局污点跟踪模块。
module CorsFlow = TaintTracking::Global<CorsBypassConfig>;

import CorsFlow::PathGraph

// 查询语句，查找潜在的不正确字符串比较，可能导致 CORS 绕过。
from CorsFlow::PathNode source, CorsFlow::PathNode sink
where
  CorsFlow::flowPath(source, sink) and
  (
    maybeInteresting(source.getNode().asCfgNode())
    or
    maybeInteresting(sink.getNode().asCfgNode())
  )
select sink, source, sink,
  "潜在不正确的字符串比较，可能导致 CORS 绕过。"
