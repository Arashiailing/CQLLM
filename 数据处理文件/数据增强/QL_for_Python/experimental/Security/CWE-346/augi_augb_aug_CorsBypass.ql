/**
 * @name 跨域资源共享（CORS）策略绕过
 * @description 检测使用弱比较器（如 'string.startswith'）检查用户提供的源标头，可能导致 CORS 策略被绕过的安全漏洞。
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
 * 通过匹配字符串中是否包含 CORS 相关关键词（"origin" 或 "cors"）进行启发式判断
 */
bindingset[s]
predicate containsCorsKeywords(string s) { s.matches(["%origin%", "%cors%"]) }

/**
 * 表示字符串前缀检查操作，特指对 'startswith' 方法的调用
 */
private class StringPrefixCheck extends ControlFlowNode {
  StringPrefixCheck() { this.(CallNode).getFunction().(AttrNode).getName() = "startswith" }
}

/**
 * 判断控制流节点是否与 CORS 相关，用于减少误报
 * 
 * 通过以下三种启发式规则进行判断：
 * 1. 检查调用函数的变量名（如 origin.startswith("...")）
 * 2. 检查作为参数的变量名（如 "...".startswith(origin)）
 * 3. 检查值写入的变量名（如 origin = ...）
 */
private predicate isCorsRelated(ControlFlowNode cfgNode) {
  // 情况1：调用函数的变量名包含 CORS 关键词（汇点）
  isCorsRelatedByFunctionObject(cfgNode)
  or
  // 情况2：作为参数的变量名包含 CORS 关键词（汇点）
  isCorsRelatedByArgument(cfgNode)
  or
  // 情况3：值写入的变量名包含 CORS 关键词（源点）
  isCorsRelatedByVariableAssignment(cfgNode)
}

/**
 * 辅助谓词：通过调用函数的变量名判断是否与 CORS 相关
 */
private predicate isCorsRelatedByFunctionObject(ControlFlowNode cfgNode) {
  exists(string variableName | 
    containsCorsKeywords(variableName) and 
    cfgNode.(CallNode).getFunction().(AttrNode).getObject().(NameNode).getId() = variableName
  )
}

/**
 * 辅助谓词：通过参数变量名判断是否与 CORS 相关
 */
private predicate isCorsRelatedByArgument(ControlFlowNode cfgNode) {
  exists(string variableName | 
    containsCorsKeywords(variableName) and 
    cfgNode.(CallNode).getArg(0).(NameNode).getId() = variableName
  )
}

/**
 * 辅助谓词：通过变量赋值判断是否与 CORS 相关
 */
private predicate isCorsRelatedByVariableAssignment(ControlFlowNode cfgNode) {
  exists(Variable var | 
    containsCorsKeywords(var.getId()) and 
    cfgNode.getASuccessor*().getNode() = var.getAStore()
  )
}

/**
 * 表示 CherryPy 框架的请求对象成员，这些对象作为远程流源被识别
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

/**
 * CORS 绕过分析配置模块，定义数据流源、汇和额外流步骤
 */
module CorsBypassConfig implements DataFlow::ConfigSig {
  /**
   * 定义数据流源：所有远程流源，包括用户输入和请求参数
   */
  predicate isSource(DataFlow::Node dataSource) { 
    dataSource instanceof RemoteFlowSource 
  }

  /**
   * 定义数据流汇：前缀检查方法的参数或调用对象
   */
  predicate isSink(DataFlow::Node dataSink) {
    exists(StringPrefixCheck prefixCheck |
      dataSink.asCfgNode() = prefixCheck.(CallNode).getArg(0) or
      dataSink.asCfgNode() = prefixCheck.(CallNode).getFunction().(AttrNode).getObject()
    )
  }

  /**
   * 定义额外流步骤：处理 cherrypy.request.headers.get() 调用
   */
  predicate isAdditionalFlowStep(DataFlow::Node sourceNode, DataFlow::Node targetNode) {
    handlesCherryPyHeadersGetCall(sourceNode, targetNode)
  }

  /**
   * 辅助谓词：处理 cherrypy.request.headers.get() 调用的流步骤
   */
  private predicate handlesCherryPyHeadersGetCall(DataFlow::Node sourceNode, DataFlow::Node targetNode) {
    exists(API::CallNode apiCall, API::Node headersNode |
      headersNode = API::moduleImport("cherrypy").getMember("request").getMember("headers") and
      apiCall = headersNode.getMember("get").getACall()
    |
      apiCall.getReturn().asSource() = targetNode and 
      headersNode.asSource() = sourceNode
    )
  }

  // 启用增量模式差异观察
  predicate observeDiffInformedIncrementalMode() { any() }
}

// 全局污点跟踪模块
module CorsFlow = TaintTracking::Global<CorsBypassConfig>;

import CorsFlow::PathGraph

/**
 * 查询潜在的 CORS 策略绕过漏洞
 */
from CorsFlow::PathNode sourceNode, CorsFlow::PathNode sinkNode
where
  CorsFlow::flowPath(sourceNode, sinkNode) and
  (
    isCorsRelated(sourceNode.getNode().asCfgNode())
    or
    isCorsRelated(sinkNode.getNode().asCfgNode())
  )
select sinkNode, sourceNode, sinkNode,
  "检测到潜在不安全的字符串比较操作，可能导致 CORS 策略被绕过。"