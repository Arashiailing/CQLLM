/**
 * @name 跨域资源共享（CORS）策略配置缺陷
 * @description 使用不安全的字符串前缀比较（如 'startswith'）验证用户提供的 Origin 头部，
 *              可能导致 CORS 安全机制被绕过，引发跨域攻击风险。
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
 * 判断输入字符串是否匹配 CORS 相关标识符模式
 */
bindingset[inputStr]
predicate containsCorsIdentifiers(string inputStr) { 
  inputStr.matches(["%origin%", "%cors%"]) 
}

/**
 * 表示使用不安全的字符串前缀比较（如startswith）的代码节点
 */
private class InsecurePrefixCheck extends ControlFlowNode {
  InsecurePrefixCheck() { 
    this.(CallNode).getFunction().(AttrNode).getName() = "startswith" 
  }
}

/**
 * 识别与 CORS 处理逻辑相关的代码节点
 * 
 * 通过以下启发式规则检测 CORS 验证逻辑：
 * 1. 调用对象包含 CORS 关键字（作为汇点）
 * 2. 方法参数包含 CORS 关键字（作为汇点）
 * 3. 变量赋值涉及 CORS 关键字（作为源点）
 */
private predicate isCorsRelatedNode(ControlFlowNode node) {
  // 场景1：调用对象包含 CORS 关键字（汇点）
  exists(string corsKeyword | 
    containsCorsIdentifiers(corsKeyword) and 
    node.(CallNode).getFunction().(AttrNode).getObject().(NameNode).getId() = corsKeyword
  )
  or
  // 场景2：方法参数包含 CORS 关键字（汇点）
  exists(string corsKeyword | 
    containsCorsIdentifiers(corsKeyword) and 
    node.(CallNode).getArg(0).(NameNode).getId() = corsKeyword
  )
  or
  // 场景3：变量赋值包含 CORS 关键字（源点）
  exists(Variable corsVar | 
    containsCorsIdentifiers(corsVar.getId()) and 
    node.getASuccessor*().getNode() = corsVar.getAStore()
  )
}

/**
 * 表示 CherryPy 框架的请求对象成员
 * 作为远程输入源被识别
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
 * CORS 安全策略绕过分析配置模块
 */
module CorsBypassAnalysisConfig implements DataFlow::ConfigSig {
  /**
   * 定义数据流源：所有远程输入源
   */
  predicate isSource(DataFlow::Node node) { 
    node instanceof RemoteFlowSource 
  }

  /**
   * 定义数据流汇：startswith 方法的参数或调用对象
   */
  predicate isSink(DataFlow::Node node) {
    exists(InsecurePrefixCheck prefixCheck |
      node.asCfgNode() = prefixCheck.(CallNode).getArg(0) or
      node.asCfgNode() = prefixCheck.(CallNode).getFunction().(AttrNode).getObject()
    )
  }

  /**
   * 定义额外流步骤：处理 cherrypy.request.headers.get() 调用链
   */
  predicate isAdditionalFlowStep(DataFlow::Node sourceNode, DataFlow::Node targetNode) {
    exists(API::CallNode headersGetMethodCall, API::Node cherrypyRequestHeaders |
      cherrypyRequestHeaders = API::moduleImport("cherrypy")
                          .getMember("request")
                          .getMember("headers") and
      headersGetMethodCall = cherrypyRequestHeaders.getMember("get").getACall()
    |
      headersGetMethodCall.getReturn().asSource() = targetNode and 
      cherrypyRequestHeaders.asSource() = sourceNode
    )
  }

  // 启用增量模式差异观察
  predicate observeDiffInformedIncrementalMode() { any() }
}

// 全局污点跟踪模块
module CorsBypassFlow = TaintTracking::Global<CorsBypassAnalysisConfig>;

import CorsBypassFlow::PathGraph

/**
 * 检测潜在的 CORS 策略配置缺陷（使用不安全的字符串前缀比较）
 */
from CorsBypassFlow::PathNode sourceNode, CorsBypassFlow::PathNode sinkNode
where
  CorsBypassFlow::flowPath(sourceNode, sinkNode) and
  (
    isCorsRelatedNode(sourceNode.getNode().asCfgNode())
    or
    isCorsRelatedNode(sinkNode.getNode().asCfgNode())
  )
select sinkNode, sourceNode, sinkNode,
  "使用弱字符串比较验证 Origin 头部，可能导致 CORS 安全策略被绕过。"