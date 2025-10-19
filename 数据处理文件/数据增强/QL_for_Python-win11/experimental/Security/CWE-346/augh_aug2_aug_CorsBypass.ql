/**
 * @name 跨域资源共享（CORS）策略绕过检测
 * @description 当使用弱字符串比较方法（如 'string.startswith'）验证用户提供的 Origin 头部时，
 *              可能导致 CORS 安全策略被绕过，引发安全风险。
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
 * 检测输入字符串是否包含 CORS 相关关键词
 */
bindingset[strInput]
predicate hasCorsKeyword(string strInput) { 
  strInput.matches(["%origin%", "%cors%"]) 
}

/**
 * 表示字符串前缀检查方法调用节点
 */
private class StringPrefixCheck extends ControlFlowNode {
  StringPrefixCheck() { 
    this.(CallNode).getFunction().(AttrNode).getName() = "startswith" 
  }
}

/**
 * 判断控制流节点是否与 CORS 验证相关
 * 
 * 通过以下启发式方法识别 CORS 验证代码：
 * 1. 调用函数的变量名包含 CORS 关键词（如 origin.startswith("...")）
 * 2. 作为参数的变量名包含 CORS 关键词（如 "...".startswith(origin)）
 * 3. 值写入的变量名包含 CORS 关键词（如 origin = ...）
 */
private predicate corsRelatedNode(ControlFlowNode cfgNode) {
  // 情况1：调用函数的变量名包含 CORS 关键词（汇点）
  exists(string corsIdentifier | 
    hasCorsKeyword(corsIdentifier) and 
    cfgNode.(CallNode).getFunction().(AttrNode).getObject().(NameNode).getId() = corsIdentifier
  )
  or
  // 情况2：作为参数的变量名包含 CORS 关键词（汇点）
  exists(string corsIdentifier | 
    hasCorsKeyword(corsIdentifier) and 
    cfgNode.(CallNode).getArg(0).(NameNode).getId() = corsIdentifier
  )
  or
  // 情况3：值写入的变量名包含 CORS 关键词（源点）
  exists(Variable corsVar | 
    hasCorsKeyword(corsVar.getId()) and 
    cfgNode.getASuccessor*().getNode() = corsVar.getAStore()
  )
}

/**
 * CherryPy 框架请求对象成员
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
 * CORS 安全绕过分析配置模块
 */
module CorsBypassConfig implements DataFlow::ConfigSig {
  /**
   * 定义数据流源：所有远程流源
   */
  predicate isSource(DataFlow::Node flowNode) { 
    flowNode instanceof RemoteFlowSource 
  }

  /**
   * 定义数据流汇：startswith 方法的参数或调用对象
   */
  predicate isSink(DataFlow::Node flowNode) {
    exists(StringPrefixCheck prefixCheck |
      flowNode.asCfgNode() = prefixCheck.(CallNode).getArg(0) or
      flowNode.asCfgNode() = prefixCheck.(CallNode).getFunction().(AttrNode).getObject()
    )
  }

  /**
   * 定义额外流步骤：处理 cherrypy.request.headers.get() 调用
   */
  predicate isAdditionalFlowStep(DataFlow::Node sourceNode, DataFlow::Node targetNode) {
    exists(API::CallNode apiCall, API::Node requestHeadersNode |
      requestHeadersNode = API::moduleImport("cherrypy").getMember("request").getMember("headers") and
      apiCall = requestHeadersNode.getMember("get").getACall()
    |
      apiCall.getReturn().asSource() = targetNode and 
      requestHeadersNode.asSource() = sourceNode
    )
  }

  // 启用增量模式差异观察
  predicate observeDiffInformedIncrementalMode() { any() }
}

// 全局污点跟踪模块
module CorsBypassFlow = TaintTracking::Global<CorsBypassConfig>;

import CorsBypassFlow::PathGraph

/**
 * 查询潜在 CORS 策略绕过漏洞
 */
from CorsBypassFlow::PathNode sourcePath, CorsBypassFlow::PathNode sinkPath
where
  CorsBypassFlow::flowPath(sourcePath, sinkPath) and
  (
    corsRelatedNode(sourcePath.getNode().asCfgNode())
    or
    corsRelatedNode(sinkPath.getNode().asCfgNode())
  )
select sinkPath, sourcePath, sinkPath,
  "使用弱字符串比较验证 Origin 头部，可能导致 CORS 安全策略被绕过。"