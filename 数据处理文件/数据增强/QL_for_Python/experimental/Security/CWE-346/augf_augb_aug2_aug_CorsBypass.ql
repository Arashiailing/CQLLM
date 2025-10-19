/**
 * @name 跨域资源共享（CORS）策略配置缺陷
 * @description 检测使用不安全的字符串前缀比较（如 'startswith'）验证用户提供的 Origin 头部，
 *              这种做法可能导致 CORS 安全机制被绕过，引发跨域攻击风险。
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
 * 检查输入字符串是否包含与 CORS 相关的关键字标识符
 */
bindingset[inputStr]
predicate containsCorsKeywords(string inputStr) { 
  inputStr.matches(["%origin%", "%cors%"]) 
}

/**
 * 表示存在安全风险的字符串前缀比较调用
 */
private class InsecurePrefixCheck extends ControlFlowNode {
  InsecurePrefixCheck() { 
    this.(CallNode).getFunction().(AttrNode).getName() = "startswith" 
  }
}

/**
 * 表示 CherryPy 框架的请求对象成员
 * 这些成员被识别为远程输入源
 */
class CherryPyRequestMember extends RemoteFlowSource::Range {
  CherryPyRequestMember() {
    this =
      API::moduleImport("cherrypy")
          .getMember("request")
          .getMember([
              "charset", "content_type", "filename", "fp", "name", 
              "params", "headers", "length"
            ])
          .asSource()
  }

  override string getSourceType() { 
    result = "cherrypy.request" 
  }
}

/**
 * 识别与 CORS 处理相关的代码节点
 * 
 * 基于以下启发式规则检测 CORS 验证逻辑：
 * 1. 检查调用对象是否包含 CORS 关键字（作为潜在汇点）
 * 2. 检查方法参数是否包含 CORS 关键字（作为潜在汇点）
 * 3. 检查变量赋值是否涉及 CORS 关键字（作为潜在源点）
 */
private predicate isCorsRelated(ControlFlowNode node) {
  // 场景1：调用对象包含 CORS 关键字（作为汇点）
  exists(string corsIdentifier | 
    containsCorsKeywords(corsIdentifier) and 
    node.(CallNode).getFunction().(AttrNode).getObject().(NameNode).getId() = corsIdentifier
  )
  or
  // 场景2：方法参数包含 CORS 关键字（作为汇点）
  exists(string corsIdentifier | 
    containsCorsKeywords(corsIdentifier) and 
    node.(CallNode).getArg(0).(NameNode).getId() = corsIdentifier
  )
  or
  // 场景3：变量赋值包含 CORS 关键字（作为源点）
  exists(Variable corsVariable | 
    containsCorsKeywords(corsVariable.getId()) and 
    node.getASuccessor*().getNode() = corsVariable.getAStore()
  )
}

/**
 * CORS 安全策略绕过分析配置模块
 */
module CorsSecurityConfig implements DataFlow::ConfigSig {
  /**
   * 定义数据流源：所有远程输入源
   */
  predicate isSource(DataFlow::Node source) { 
    source instanceof RemoteFlowSource 
  }

  /**
   * 定义数据流汇：startswith 方法的参数或调用对象
   */
  predicate isSink(DataFlow::Node sink) {
    exists(InsecurePrefixCheck prefixCheck |
      sink.asCfgNode() = prefixCheck.(CallNode).getArg(0) or
      sink.asCfgNode() = prefixCheck.(CallNode).getFunction().(AttrNode).getObject()
    )
  }

  /**
   * 定义额外流步骤：处理 cherrypy.request.headers.get() 调用链
   */
  predicate isAdditionalFlowStep(DataFlow::Node prevNode, DataFlow::Node nextNode) {
    exists(API::CallNode headersCall, API::Node requestHeaders |
      requestHeaders = API::moduleImport("cherrypy")
                          .getMember("request")
                          .getMember("headers") and
      headersCall = requestHeaders.getMember("get").getACall()
    |
      headersCall.getReturn().asSource() = nextNode and 
      requestHeaders.asSource() = prevNode
    )
  }

  // 启用增量模式差异观察
  predicate observeDiffInformedIncrementalMode() { any() }
}

// 全局污点跟踪模块
module CorsBypassFlow = TaintTracking::Global<CorsSecurityConfig>;

import CorsBypassFlow::PathGraph

/**
 * 查询潜在的 CORS 策略绕过漏洞
 */
from CorsBypassFlow::PathNode entryPoint, CorsBypassFlow::PathNode vulnerablePoint
where
  CorsBypassFlow::flowPath(entryPoint, vulnerablePoint) and
  (
    isCorsRelated(entryPoint.getNode().asCfgNode())
    or
    isCorsRelated(vulnerablePoint.getNode().asCfgNode())
  )
select vulnerablePoint, entryPoint, vulnerablePoint,
  "使用弱字符串比较验证 Origin 头部，可能导致 CORS 安全策略被绕过。"