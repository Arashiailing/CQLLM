/**
 * @name 跨域资源共享（CORS）策略配置缺陷
 * @description 检测使用不安全的字符串前缀比较（如 'startswith'）验证用户提供的 Origin 头部，
 *              这种实现方式可能导致 CORS 安全机制被绕过，从而引发跨域攻击风险。
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

// ======== 辅助谓词和类定义 ========

/**
 * 判断输入字符串是否包含 CORS 相关标识符
 * 用于识别与 CORS 处理相关的代码节点
 */
bindingset[inputStr]
predicate containsCorsKeywords(string inputStr) { 
  inputStr.matches(["%origin%", "%cors%"]) 
}

/**
 * 表示不安全的字符串前缀比较调用
 * 这类调用通常用于验证 Origin 头部，但存在安全风险
 */
private class UnsafeStringPrefixComparison extends ControlFlowNode {
  UnsafeStringPrefixComparison() { 
    this.(CallNode).getFunction().(AttrNode).getName() = "startswith" 
  }
}

/**
 * 表示 CherryPy 框架的请求对象成员
 * 这些成员被视为远程输入源，可能包含用户提供的 Origin 头部
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

// ======== CORS 相关节点识别 ========

/**
 * 识别与 CORS 处理相关的代码节点
 * 
 * 通过以下启发式规则检测 CORS 验证逻辑：
 * 1. 检查调用对象是否包含 CORS 关键字（作为汇点）
 * 2. 检查方法参数是否包含 CORS 关键字（作为汇点）
 * 3. 检查变量赋值是否涉及 CORS 关键字（作为源点）
 */
private predicate isCorsRelated(ControlFlowNode codeNode) {
  // 场景1：调用对象包含 CORS 关键字（汇点）
  exists(string corsIdentifier | 
    containsCorsKeywords(corsIdentifier) and 
    codeNode.(CallNode).getFunction().(AttrNode).getObject().(NameNode).getId() = corsIdentifier
  )
  or
  // 场景2：方法参数包含 CORS 关键字（汇点）
  exists(string corsIdentifier | 
    containsCorsKeywords(corsIdentifier) and 
    codeNode.(CallNode).getArg(0).(NameNode).getId() = corsIdentifier
  )
  or
  // 场景3：变量赋值包含 CORS 关键字（源点）
  exists(Variable corsVariable | 
    containsCorsKeywords(corsVariable.getId()) and 
    codeNode.getASuccessor*().getNode() = corsVariable.getAStore()
  )
}

// ======== 数据流配置 ========

/**
 * CORS 安全策略绕过分析配置
 * 定义数据流源、汇和额外流步骤
 */
module CorsBypassConfig implements DataFlow::ConfigSig {
  /**
   * 定义数据流源：所有远程输入源
   * 包括 CherryPy 请求对象和其他远程输入源
   */
  predicate isSource(DataFlow::Node flowSource) { 
    flowSource instanceof RemoteFlowSource 
  }

  /**
   * 定义数据流汇：startswith 方法的参数或调用对象
   * 这些位置通常用于验证 Origin 头部
   */
  predicate isSink(DataFlow::Node flowSink) {
    exists(UnsafeStringPrefixComparison prefixComparison |
      flowSink.asCfgNode() = prefixComparison.(CallNode).getArg(0) or
      flowSink.asCfgNode() = prefixComparison.(CallNode).getFunction().(AttrNode).getObject()
    )
  }

  /**
   * 定义额外流步骤：处理 cherrypy.request.headers.get() 调用链
   * 确保数据流能够正确跟踪从请求头到验证逻辑的路径
   */
  predicate isAdditionalFlowStep(DataFlow::Node sourceNode, DataFlow::Node targetNode) {
    exists(API::CallNode headersGetMethod, API::Node requestHeaders |
      requestHeaders = API::moduleImport("cherrypy")
                          .getMember("request")
                          .getMember("headers") and
      headersGetMethod = requestHeaders.getMember("get").getACall()
    |
      headersGetMethod.getReturn().asSource() = targetNode and 
      requestHeaders.asSource() = sourceNode
    )
  }

  // 启用增量模式差异观察
  predicate observeDiffInformedIncrementalMode() { any() }
}

// ======== 污点跟踪模块 ========

// 全局污点跟踪模块
module CorsBypassFlow = TaintTracking::Global<CorsBypassConfig>;

import CorsBypassFlow::PathGraph

// ======== 主查询 ========

/**
 * 查询潜在的 CORS 策略绕过漏洞
 * 检测从远程输入源到不安全字符串前缀比较的数据流路径
 */
from CorsBypassFlow::PathNode sourcePathNode, CorsBypassFlow::PathNode sinkPathNode
where
  CorsBypassFlow::flowPath(sourcePathNode, sinkPathNode) and
  (
    isCorsRelated(sourcePathNode.getNode().asCfgNode())
    or
    isCorsRelated(sinkPathNode.getNode().asCfgNode())
  )
select sinkPathNode, sourcePathNode, sinkPathNode,
  "使用弱字符串比较验证 Origin 头部，可能导致 CORS 安全策略被绕过。"