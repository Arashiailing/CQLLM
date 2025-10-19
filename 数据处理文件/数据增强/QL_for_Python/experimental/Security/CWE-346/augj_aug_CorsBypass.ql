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
 * 检查字符串是否符合启发式规则（包含"origin"或"cors"）
 */
bindingset[s]
predicate heuristics(string s) { s.matches(["%origin%", "%cors%"]) }

/**
 * 表示字符串的 startswith 方法调用
 */
private class StringStartswithMethodCall extends ControlFlowNode {
  StringStartswithMethodCall() { 
    this.(CallNode).getFunction().(AttrNode).getName() = "startswith" 
  }
}

/**
 * 判断控制流节点是否值得分析
 * 
 * 通过启发式规则过滤节点，减少误报：
 * 1. 检查调用函数的变量名（如 origin.startswith("...")）
 * 2. 检查作为参数的变量名（如 "...".startswith(origin)）
 * 3. 检查值写入的变量名（如 origin = ...）
 */
private predicate isNodeInteresting(ControlFlowNode node) {
  // 情况1：调用函数的变量名符合规则（汇点）
  exists(string varName | 
    heuristics(varName) and 
    node.(CallNode).getFunction().(AttrNode).getObject().(NameNode).getId() = varName
  )
  or
  // 情况2：作为参数的变量名符合规则（汇点）
  exists(string varName | 
    heuristics(varName) and 
    node.(CallNode).getArg(0).(NameNode).getId() = varName
  )
  or
  // 情况3：值写入的变量名符合规则（源点）
  exists(Variable var | 
    heuristics(var.getId()) and 
    node.getASuccessor*().getNode() = var.getAStore()
  )
}

/**
 * 表示 CherryPy 框架的请求对象成员
 * 作为远程流源被识别
 */
class CherryPyRequestSource extends RemoteFlowSource::Range {
  CherryPyRequestSource() {
    this =
      API::moduleImport("cherrypy")
          .getMember("request")
          .getMember([
              "charset", "content_type", "filename", "fp", "name", "params", "headers", "length"
            ])
          .asSource()
  }

  override string getSourceType() { result = "cherrypy.request" }
}

/**
 * CORS 绕过分析配置模块
 */
module CorsBypassAnalysisConfig implements DataFlow::ConfigSig {
  /**
   * 定义数据流源：所有远程流源
   */
  predicate isSource(DataFlow::Node flowElement) { 
    flowElement instanceof RemoteFlowSource 
  }

  /**
   * 定义数据流汇：startswith 方法的参数或调用对象
   */
  predicate isSink(DataFlow::Node flowElement) {
    exists(StringStartswithMethodCall methodCall |
      flowElement.asCfgNode() = methodCall.(CallNode).getArg(0) or
      flowElement.asCfgNode() = methodCall.(CallNode).getFunction().(AttrNode).getObject()
    )
  }

  /**
   * 定义额外流步骤：处理 cherrypy.request.headers.get() 调用
   */
  predicate isAdditionalFlowStep(DataFlow::Node fromNode, DataFlow::Node toNode) {
    exists(API::CallNode apiCall, API::Node headersNode |
      headersNode = API::moduleImport("cherrypy").getMember("request").getMember("headers") and
      apiCall = headersNode.getMember("get").getACall()
    |
      apiCall.getReturn().asSource() = toNode and 
      headersNode.asSource() = fromNode
    )
  }

  // 启用增量模式差异观察
  predicate observeDiffInformedIncrementalMode() { any() }
}

// 全局污点跟踪模块
module CorsTaintFlow = TaintTracking::Global<CorsBypassAnalysisConfig>;

import CorsTaintFlow::PathGraph

/**
 * 查询潜在 CORS 策略绕过漏洞
 */
from CorsTaintFlow::PathNode sourcePathNode, CorsTaintFlow::PathNode sinkPathNode
where
  CorsTaintFlow::flowPath(sourcePathNode, sinkPathNode) and
  (
    isNodeInteresting(sourcePathNode.getNode().asCfgNode())
    or
    isNodeInteresting(sinkPathNode.getNode().asCfgNode())
  )
select sinkPathNode, sourcePathNode, sinkPathNode,
  "潜在不正确的字符串比较，可能导致 CORS 绕过。"