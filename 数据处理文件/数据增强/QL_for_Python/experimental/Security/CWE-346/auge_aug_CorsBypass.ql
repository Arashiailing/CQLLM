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
 * 判断字符串是否包含 CORS 相关关键词
 * 用于启发式识别与 CORS 相关的变量和代码
 */
bindingset[s]
predicate containsCorsKeywords(string s) { s.matches(["%origin%", "%cors%"]) }

/**
 * 表示对字符串对象调用 startswith 方法的控制流节点
 * 这种调用模式常被错误地用于验证 Origin 头部
 */
private class StrStartswithMethodCall extends ControlFlowNode {
  StrStartswithMethodCall() { 
    this.(CallNode).getFunction().(AttrNode).getName() = "startswith" 
  }
}

/**
 * 检查变量名是否包含 CORS 相关关键词
 */
private predicate hasCorsRelevantName(Variable variable) { 
  containsCorsKeywords(variable.getId()) 
}

/**
 * 检查控制流节点是否与 CORS 验证逻辑相关
 * 通过三种启发式规则识别潜在感兴趣的节点，减少误报
 */
private predicate isCorsRelevantNode(ControlFlowNode controlFlowNode) {
  // 规则1：调用startswith方法的变量名包含CORS关键词（作为方法调用者）
  exists(string variableName | 
    containsCorsKeywords(variableName) and 
    controlFlowNode.(CallNode).getFunction().(AttrNode).getObject().(NameNode).getId() = variableName
  )
  or
  // 规则2：作为startswith方法参数的变量名包含CORS关键词
  exists(string variableName | 
    containsCorsKeywords(variableName) and 
    controlFlowNode.(CallNode).getArg(0).(NameNode).getId() = variableName
  )
  or
  // 规则3：值被写入包含CORS关键词的变量（潜在源点）
  exists(Variable variable | 
    hasCorsRelevantName(variable) and 
    controlFlowNode.getASuccessor*().getNode() = variable.getAStore()
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
  predicate isSource(DataFlow::Node flowNode) { 
    flowNode instanceof RemoteFlowSource 
  }

  /**
   * 定义数据流汇：字符串 startswith 方法的调用对象或参数
   * 这些位置常用于不安全的 Origin 验证
   */
  predicate isSink(DataFlow::Node flowNode) {
    exists(StrStartswithMethodCall strStartswithCall |
      flowNode.asCfgNode() = strStartswithCall.(CallNode).getArg(0) or
      flowNode.asCfgNode() = strStartswithCall.(CallNode).getFunction().(AttrNode).getObject()
    )
  }

  /**
   * 定义额外的数据流步骤：处理 cherrypy.request.headers.get() 调用
   * 这种调用模式常见于获取请求头部的场景
   */
  predicate isAdditionalFlowStep(DataFlow::Node sourceNode, DataFlow::Node targetNode) {
    exists(API::CallNode apiMethodCall, API::Node requestHeadersNode |
      requestHeadersNode = API::moduleImport("cherrypy").getMember("request").getMember("headers") and
      apiMethodCall = requestHeadersNode.getMember("get").getACall()
    |
      apiMethodCall.getReturn().asSource() = targetNode and 
      requestHeadersNode.asSource() = sourceNode
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
from CorsTaintFlow::PathNode pathSourceNode, CorsTaintFlow::PathNode pathSinkNode
where
  CorsTaintFlow::flowPath(pathSourceNode, pathSinkNode) and
  (
    isCorsRelevantNode(pathSourceNode.getNode().asCfgNode())
    or
    isCorsRelevantNode(pathSinkNode.getNode().asCfgNode())
  )
select pathSinkNode, pathSourceNode, pathSinkNode,
  "使用弱字符串比较验证 Origin 头部可能导致 CORS 策略被绕过。"