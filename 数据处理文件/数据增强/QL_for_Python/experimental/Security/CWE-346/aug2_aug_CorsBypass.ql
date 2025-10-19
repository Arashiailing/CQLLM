/**
 * @name 跨域资源共享（CORS）策略绕过
 * @description 通过使用弱字符串比较方法（如 'string.startswith'）验证用户提供的 Origin 头部，
 *              可能导致 CORS 安全策略被绕过。
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
 * 判断输入字符串是否包含与 CORS 相关的关键词
 */
bindingset[inputStr]
predicate containsCorsKeywords(string inputStr) { 
  inputStr.matches(["%origin%", "%cors%"]) 
}

/**
 * 表示字符串前缀检查方法调用
 */
private class PrefixCheckCall extends ControlFlowNode {
  PrefixCheckCall() { 
    this.(CallNode).getFunction().(AttrNode).getName() = "startswith" 
  }
}

/**
 * 检查控制流节点是否与 CORS 相关
 * 
 * 使用启发式方法识别可能涉及 CORS 验证的代码节点：
 * 1. 检查调用函数的变量名（如 origin.startswith("...")）
 * 2. 检查作为参数的变量名（如 "...".startswith(origin)）
 * 3. 检查值写入的变量名（如 origin = ...）
 */
private predicate isCorsRelated(ControlFlowNode flowNode) {
  // 情况1：调用函数的变量名包含 CORS 关键词（汇点）
  exists(string identifier | 
    containsCorsKeywords(identifier) and 
    flowNode.(CallNode).getFunction().(AttrNode).getObject().(NameNode).getId() = identifier
  )
  or
  // 情况2：作为参数的变量名包含 CORS 关键词（汇点）
  exists(string identifier | 
    containsCorsKeywords(identifier) and 
    flowNode.(CallNode).getArg(0).(NameNode).getId() = identifier
  )
  or
  // 情况3：值写入的变量名包含 CORS 关键词（源点）
  exists(Variable var | 
    containsCorsKeywords(var.getId()) and 
    flowNode.getASuccessor*().getNode() = var.getAStore()
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

  override string getSourceType() { 
    result = "cherrypy.request" 
  }
}

/**
 * CORS 安全绕过分析配置
 */
module CorsSecurityConfig implements DataFlow::ConfigSig {
  /**
   * 定义数据流源：所有远程流源
   */
  predicate isSource(DataFlow::Node dataFlowNode) { 
    dataFlowNode instanceof RemoteFlowSource 
  }

  /**
   * 定义数据流汇：startswith 方法的参数或调用对象
   */
  predicate isSink(DataFlow::Node dataFlowNode) {
    exists(PrefixCheckCall prefixCheck |
      dataFlowNode.asCfgNode() = prefixCheck.(CallNode).getArg(0) or
      dataFlowNode.asCfgNode() = prefixCheck.(CallNode).getFunction().(AttrNode).getObject()
    )
  }

  /**
   * 定义额外流步骤：处理 cherrypy.request.headers.get() 调用
   */
  predicate isAdditionalFlowStep(DataFlow::Node sourceNode, DataFlow::Node targetNode) {
    exists(API::CallNode apiInvocation, API::Node requestHeadersNode |
      requestHeadersNode = API::moduleImport("cherrypy").getMember("request").getMember("headers") and
      apiInvocation = requestHeadersNode.getMember("get").getACall()
    |
      apiInvocation.getReturn().asSource() = targetNode and 
      requestHeadersNode.asSource() = sourceNode
    )
  }

  // 启用增量模式差异观察
  predicate observeDiffInformedIncrementalMode() { any() }
}

// 全局污点跟踪模块
module CorsSecurityFlow = TaintTracking::Global<CorsSecurityConfig>;

import CorsSecurityFlow::PathGraph

/**
 * 查询潜在 CORS 策略绕过漏洞
 */
from CorsSecurityFlow::PathNode pathSource, CorsSecurityFlow::PathNode pathSink
where
  CorsSecurityFlow::flowPath(pathSource, pathSink) and
  (
    isCorsRelated(pathSource.getNode().asCfgNode())
    or
    isCorsRelated(pathSink.getNode().asCfgNode())
  )
select pathSink, pathSource, pathSink,
  "使用弱字符串比较验证 Origin 头部，可能导致 CORS 安全策略被绕过。"