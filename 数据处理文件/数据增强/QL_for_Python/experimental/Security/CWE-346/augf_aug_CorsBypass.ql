/**
 * @name 跨域资源共享（CORS）策略绕过
 * @description 检测使用弱比较器（如 'string.startswith'）验证用户提供的源标头时可能导致的 CORS 策略绕过漏洞。
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
 * 检查输入字符串是否符合启发式规则（包含"origin"或"cors"关键词）
 * 用于识别可能与 CORS 相关的变量和函数调用
 */
bindingset[inputStr]
predicate heuristics(string inputStr) { inputStr.matches(["%origin%", "%cors%"]) }

/**
 * 表示字符串的 startswith 方法调用
 * 这是潜在的弱比较器，可能导致 CORS 策略绕过
 */
private class StringStartswithCall extends ControlFlowNode {
  StringStartswithCall() { this.(CallNode).getFunction().(AttrNode).getName() = "startswith" }
}

/**
 * 判断控制流节点是否可能值得分析
 * 
 * 通过启发式规则过滤节点，减少误报：
 * 1. 检查调用函数的变量名（如 origin.startswith("...")）
 * 2. 检查作为参数的变量名（如 "...".startswith(origin)）
 * 3. 检查值写入的变量名（如 origin = ...）
 */
private predicate maybeInteresting(ControlFlowNode controlFlowNode) {
  // 情况1：调用函数的变量名符合规则（汇点）
  exists(string variableName | 
    heuristics(variableName) and 
    controlFlowNode.(CallNode).getFunction().(AttrNode).getObject().(NameNode).getId() = variableName
  )
  or
  // 情况2：作为参数的变量名符合规则（汇点）
  exists(string variableName | 
    heuristics(variableName) and 
    controlFlowNode.(CallNode).getArg(0).(NameNode).getId() = variableName
  )
  or
  // 情况3：值写入的变量名符合规则（源点）
  exists(Variable variable | 
    heuristics(variable.getId()) and 
    controlFlowNode.getASuccessor*().getNode() = variable.getAStore()
  )
}

/**
 * 表示 CherryPy 框架的请求对象成员
 * 作为远程流源被识别，可能包含用户控制的输入
 */
class CherryPyRequest extends RemoteFlowSource::Range {
  CherryPyRequest() {
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
 * 定义数据流分析的源、汇和额外流步骤
 */
module CorsBypassConfig implements DataFlow::ConfigSig {
  /**
   * 定义数据流源：所有远程流源
   * 包括用户输入、网络请求等外部数据
   */
  predicate isSource(DataFlow::Node flowNode) { 
    flowNode instanceof RemoteFlowSource 
  }

  /**
   * 定义数据流汇：startswith 方法的参数或调用对象
   * 这些是潜在的弱比较点，可能导致 CORS 策略绕过
   */
  predicate isSink(DataFlow::Node flowNode) {
    exists(StringStartswithCall startswithCall |
      flowNode.asCfgNode() = startswithCall.(CallNode).getArg(0) or
      flowNode.asCfgNode() = startswithCall.(CallNode).getFunction().(AttrNode).getObject()
    )
  }

  /**
   * 定义额外流步骤：处理 cherrypy.request.headers.get() 调用
   * 确保从请求头获取的数据能够正确追踪
   */
  predicate isAdditionalFlowStep(DataFlow::Node source, DataFlow::Node target) {
    exists(API::CallNode apiCall, API::Node headersNode |
      headersNode = API::moduleImport("cherrypy").getMember("request").getMember("headers") and
      apiCall = headersNode.getMember("get").getACall()
    |
      apiCall.getReturn().asSource() = target and 
      headersNode.asSource() = source
    )
  }

  // 启用增量模式差异观察
  predicate observeDiffInformedIncrementalMode() { any() }
}

// 全局污点跟踪模块
module CorsFlow = TaintTracking::Global<CorsBypassConfig>;

import CorsFlow::PathGraph

/**
 * 查询潜在 CORS 策略绕过漏洞
 * 
 * 查找从远程流源到字符串 startswith 调用的数据流路径，
 * 其中源或汇点与 CORS 相关（通过启发式规则判断）
 */
from CorsFlow::PathNode pathSource, CorsFlow::PathNode pathSink
where
  CorsFlow::flowPath(pathSource, pathSink) and
  (
    maybeInteresting(pathSource.getNode().asCfgNode())
    or
    maybeInteresting(pathSink.getNode().asCfgNode())
  )
select pathSink, pathSource, pathSink,
  "潜在不正确的字符串比较，可能导致 CORS 绕过。"