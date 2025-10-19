/**
 * @name 跨域资源共享（CORS）策略配置缺陷
 * @description 检测使用不安全字符串前缀比较（如startswith）验证Origin头部，
 *              该缺陷可能导致CORS安全机制被绕过，引发跨域攻击风险
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
 * 检查输入字符串是否包含CORS相关标识符
 */
bindingset[inputStr]
predicate containsCorsKeywords(string inputStr) { 
  inputStr.matches(["%origin%", "%cors%"]) 
}

/**
 * 表示不安全的字符串前缀比较操作
 */
private class InsecurePrefixCheck extends ControlFlowNode {
  InsecurePrefixCheck() { 
    this.(CallNode).getFunction().(AttrNode).getName() = "startswith" 
  }
}

/**
 * 识别与CORS处理相关的代码节点
 * 
 * 通过三种启发式规则检测CORS验证逻辑：
 * 1. 调用对象包含CORS关键字（作为汇点）
 * 2. 方法参数包含CORS关键字（作为汇点）
 * 3. 变量赋值涉及CORS关键字（作为源点）
 */
private predicate isCorsRelated(ControlFlowNode node) {
  // 场景1：调用对象包含CORS关键字（汇点）
  exists(string corsKeyword | 
    containsCorsKeywords(corsKeyword) and 
    node.(CallNode).getFunction().(AttrNode).getObject().(NameNode).getId() = corsKeyword
  )
  or
  // 场景2：方法参数包含CORS关键字（汇点）
  exists(string corsKeyword | 
    containsCorsKeywords(corsKeyword) and 
    node.(CallNode).getArg(0).(NameNode).getId() = corsKeyword
  )
  or
  // 场景3：变量赋值包含CORS关键字（源点）
  exists(Variable corsVar | 
    containsCorsKeywords(corsVar.getId()) and 
    node.getASuccessor*().getNode() = corsVar.getAStore()
  )
}

/**
 * 表示CherryPy框架的请求对象成员
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
 * CORS安全策略绕过分析配置
 */
module CorsBypassConfig implements DataFlow::ConfigSig {
  /**
   * 定义数据流源：所有远程输入源
   */
  predicate isSource(DataFlow::Node node) { 
    node instanceof RemoteFlowSource 
  }

  /**
   * 定义数据流汇：startswith方法的参数或调用对象
   */
  predicate isSink(DataFlow::Node node) {
    exists(InsecurePrefixCheck prefixCheck |
      node.asCfgNode() = prefixCheck.(CallNode).getArg(0) or
      node.asCfgNode() = prefixCheck.(CallNode).getFunction().(AttrNode).getObject()
    )
  }

  /**
   * 定义额外流步骤：处理cherrypy.request.headers.get()调用链
   */
  predicate isAdditionalFlowStep(DataFlow::Node sourceNode, DataFlow::Node targetNode) {
    exists(API::CallNode headersGetCall, API::Node requestHeaders |
      requestHeaders = API::moduleImport("cherrypy")
                          .getMember("request")
                          .getMember("headers") and
      headersGetCall = requestHeaders.getMember("get").getACall()
    |
      headersGetCall.getReturn().asSource() = targetNode and 
      requestHeaders.asSource() = sourceNode
    )
  }

  // 启用增量模式差异观察
  predicate observeDiffInformedIncrementalMode() { any() }
}

// 全局污点跟踪模块
module CorsBypassFlow = TaintTracking::Global<CorsBypassConfig>;

import CorsBypassFlow::PathGraph

/**
 * 查询潜在的CORS策略绕过漏洞
 */
from CorsBypassFlow::PathNode sourceNode, CorsBypassFlow::PathNode sinkNode
where
  CorsBypassFlow::flowPath(sourceNode, sinkNode) and
  (
    isCorsRelated(sourceNode.getNode().asCfgNode())
    or
    isCorsRelated(sinkNode.getNode().asCfgNode())
  )
select sinkNode, sourceNode, sinkNode,
  "使用弱字符串比较验证Origin头部，可能导致CORS安全策略被绕过。"