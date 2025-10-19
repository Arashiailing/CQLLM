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
 * 判断字符串是否包含与 CORS 相关的关键词（"origin" 或 "cors"）
 */
bindingset[s]
predicate containsCorsKeywords(string s) { s.matches(["%origin%", "%cors%"]) }

/**
 * 表示字符串前缀检查操作（startswith 方法调用）
 */
private class StringPrefixCheck extends ControlFlowNode {
  StringPrefixCheck() { this.(CallNode).getFunction().(AttrNode).getName() = "startswith" }
}

/**
 * 判断控制流节点是否与 CORS 相关，值得进一步分析
 * 
 * 通过启发式规则过滤节点，减少误报：
 * 1. 检查调用函数的变量名（如 origin.startswith("...")）
 * 2. 检查作为参数的变量名（如 "...".startswith(origin)）
 * 3. 检查值写入的变量名（如 origin = ...）
 */
private predicate isCorsRelated(ControlFlowNode node) {
  // 检查调用函数的变量名（如 origin.startswith("...")）
  exists(string corsVarName | 
    containsCorsKeywords(corsVarName) and 
    node.(CallNode).getFunction().(AttrNode).getObject().(NameNode).getId() = corsVarName
  )
  or
  // 检查作为参数的变量名（如 "...".startswith(origin)）
  exists(string corsVarName | 
    containsCorsKeywords(corsVarName) and 
    node.(CallNode).getArg(0).(NameNode).getId() = corsVarName
  )
  or
  // 检查值写入的变量名（如 origin = ...）
  exists(Variable corsVar | 
    containsCorsKeywords(corsVar.getId()) and 
    node.getASuccessor*().getNode() = corsVar.getAStore()
  )
}

/**
 * CORS 绕过分析配置模块
 */
module CorsBypassConfig implements DataFlow::ConfigSig {
  /**
   * 定义数据流源：所有远程流源
   */
  predicate isSource(DataFlow::Node sourceNode) { 
    sourceNode instanceof RemoteFlowSource 
  }

  /**
   * 定义数据流汇：前缀检查方法的参数或调用对象
   */
  predicate isSink(DataFlow::Node sinkNode) {
    exists(StringPrefixCheck prefixCheckCall |
      sinkNode.asCfgNode() = prefixCheckCall.(CallNode).getArg(0) or
      sinkNode.asCfgNode() = prefixCheckCall.(CallNode).getFunction().(AttrNode).getObject()
    )
  }

  /**
   * 定义额外流步骤：处理 cherrypy.request.headers.get() 调用
   */
  predicate isAdditionalFlowStep(DataFlow::Node headerNode, DataFlow::Node returnValueNode) {
    exists(API::CallNode apiCall, API::Node headersNode |
      headersNode = API::moduleImport("cherrypy").getMember("request").getMember("headers") and
      apiCall = headersNode.getMember("get").getACall()
    |
      apiCall.getReturn().asSource() = returnValueNode and 
      headersNode.asSource() = headerNode
    )
  }

  // 启用增量模式差异观察
  predicate observeDiffInformedIncrementalMode() { any() }
}

/**
 * 表示 CherryPy 框架的请求对象成员
 * 这些对象作为远程流源被识别
 */
class CherryPyRequestMember extends RemoteFlowSource::Range {
  CherryPyRequestMember() {
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

// 全局污点跟踪模块
module CorsFlow = TaintTracking::Global<CorsBypassConfig>;

import CorsFlow::PathGraph

/**
 * 查询潜在 CORS 策略绕过漏洞
 */
from CorsFlow::PathNode sourcePathNode, CorsFlow::PathNode sinkPathNode
where
  CorsFlow::flowPath(sourcePathNode, sinkPathNode) and
  (
    isCorsRelated(sourcePathNode.getNode().asCfgNode())
    or
    isCorsRelated(sinkPathNode.getNode().asCfgNode())
  )
select sinkPathNode, sourcePathNode, sinkPathNode,
  "潜在不正确的字符串比较，可能导致 CORS 绕过。"