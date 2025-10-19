/**
 * @name 跨域资源共享（CORS）策略绕过漏洞
 * @description 当使用弱字符串比较方法（如 'string.startswith'）验证用户提供的 Origin 头部时，
 *              可能导致 CORS 安全策略被绕过，使攻击者能够执行跨域请求。
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
 * 检测字符串中是否包含 CORS 相关关键词
 * 用于启发式识别与 CORS 相关的变量和代码
 */
bindingset[s]
predicate containsCorsKeywords(string s) { s.matches(["%origin%", "%cors%"]) }

/**
 * 表示调用字符串 startswith 方法的控制流节点
 * 此类调用模式常被错误地用于 Origin 头部验证
 */
private class StrStartswithMethodCall extends ControlFlowNode {
  StrStartswithMethodCall() { 
    this.(CallNode).getFunction().(AttrNode).getName() = "startswith" 
  }
}

/**
 * 检查变量名是否包含 CORS 相关关键词
 */
private predicate hasCorsRelevantName(Variable var) { 
  containsCorsKeywords(var.getId()) 
}

/**
 * 识别与 CORS 验证逻辑相关的控制流节点
 * 通过三种启发式规则检测潜在感兴趣的节点，降低误报率
 */
private predicate isCorsRelevantNode(ControlFlowNode cfgNode) {
  // 规则1：调用 startswith 方法的对象变量名包含 CORS 关键词
  exists(string varName | 
    containsCorsKeywords(varName) and 
    cfgNode.(CallNode).getFunction().(AttrNode).getObject().(NameNode).getId() = varName
  )
  or
  // 规则2：作为 startswith 方法参数的变量名包含 CORS 关键词
  exists(string varName | 
    containsCorsKeywords(varName) and 
    cfgNode.(CallNode).getArg(0).(NameNode).getId() = varName
  )
  or
  // 规则3：值被写入包含 CORS 关键词的变量（潜在源点）
  exists(Variable var | 
    hasCorsRelevantName(var) and 
    cfgNode.getASuccessor*().getNode() = var.getAStore()
  )
}

/**
 * 表示 CherryPy 框架中请求对象的成员访问
 * 这些成员被视为远程流源，因为它们包含用户提供的输入
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
 * CORS 策略绕过漏洞的数据流分析配置
 * 定义源、汇和额外的流步骤以识别不安全的 Origin 验证
 */
module CorsBypassAnalysisConfig implements DataFlow::ConfigSig {
  /**
   * 定义数据流源：所有远程输入源
   */
  predicate isSource(DataFlow::Node node) { 
    node instanceof RemoteFlowSource 
  }

  /**
   * 定义数据流汇：字符串 startswith 方法的调用对象或参数
   * 这些位置常用于不安全的 Origin 验证
   */
  predicate isSink(DataFlow::Node node) {
    exists(StrStartswithMethodCall startswithCall |
      node.asCfgNode() = startswithCall.(CallNode).getArg(0) or
      node.asCfgNode() = startswithCall.(CallNode).getFunction().(AttrNode).getObject()
    )
  }

  /**
   * 定义额外的数据流步骤：处理 cherrypy.request.headers.get() 调用
   * 这种调用模式常见于获取请求头部的场景
   */
  predicate isAdditionalFlowStep(DataFlow::Node srcNode, DataFlow::Node tgtNode) {
    exists(API::CallNode methodCall, API::Node headersNode |
      headersNode = API::moduleImport("cherrypy").getMember("request").getMember("headers") and
      methodCall = headersNode.getMember("get").getACall()
    |
      methodCall.getReturn().asSource() = tgtNode and 
      headersNode.asSource() = srcNode
    )
  }

  // 启用增量模式差异观察以提高分析效率
  predicate observeDiffInformedIncrementalMode() { any() }
}

// 全局污点跟踪模块，用于追踪从源到汇的数据流
module CorsTaintFlow = TaintTracking::Global<CorsBypassAnalysisConfig>;

import CorsTaintFlow::PathGraph

/**
 * 查询潜在的 CORS 策略绕过漏洞
 * 识别从用户输入到不安全字符串比较的数据流路径
 */
from CorsTaintFlow::PathNode sourcePathNode, CorsTaintFlow::PathNode sinkPathNode
where
  CorsTaintFlow::flowPath(sourcePathNode, sinkPathNode) and
  (
    isCorsRelevantNode(sourcePathNode.getNode().asCfgNode())
    or
    isCorsRelevantNode(sinkPathNode.getNode().asCfgNode())
  )
select sinkPathNode, sourcePathNode, sinkPathNode,
  "使用弱字符串比较验证 Origin 头部可能导致 CORS 策略被绕过。"